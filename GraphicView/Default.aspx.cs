using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GraphicView
{
    /// <summary>
    /// Code-behind for the Age/Sex Population Pyramid page.
    ///
    /// Flow:
    ///   1. Page_Load populates the Year and Region dropdowns from the database
    ///      (first visit only).
    ///   2. When the user clicks "Show Pyramid", btnShow_Click calls LoadChartData
    ///      which queries PopulationData filtered by the chosen options, serialises
    ///      the results into JSON hidden fields, and binds the summary GridView.
    ///   3. The Chart.js script in Default.aspx reads those hidden fields and
    ///      renders the horizontal bar (pyramid) chart on the client side.
    /// </summary>
    public partial class Default : Page
    {
        // =====================================================================
        // Page lifecycle
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    PopulateFilterDropdowns();
                }
                catch (Exception ex)
                {
                    ShowWarning("Could not load filter options: " + ex.Message
                        + "  Please verify the connection string in web.config.");
                }
            }
        }

        // =====================================================================
        // Event handlers
        // =====================================================================

        protected void btnShow_Click(object sender, EventArgs e)
        {
            try
            {
                LoadChartData();
            }
            catch (Exception ex)
            {
                ShowWarning("Error loading pyramid data: " + ex.Message);
            }
        }

        // =====================================================================
        // Private helpers
        // =====================================================================

        /// <summary>
        /// Queries distinct Years and Regions from the database and adds them to
        /// the corresponding DropDownLists (keeping the "All" item at position 0).
        /// </summary>
        private void PopulateFilterDropdowns()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["GraphicViewDB"].ConnectionString;

            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Years – newest first
                using (var cmd = new SqlCommand(
                    "SELECT DISTINCT [Year] FROM dbo.PopulationData ORDER BY [Year] DESC",
                    conn))
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string yr = rdr["Year"].ToString();
                        ddlYear.Items.Add(new ListItem(yr, yr));
                    }
                }

                // Regions – alphabetical
                using (var cmd = new SqlCommand(
                    "SELECT DISTINCT Region FROM dbo.PopulationData ORDER BY Region",
                    conn))
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string reg = rdr["Region"].ToString();
                        ddlRegion.Items.Add(new ListItem(reg, reg));
                    }
                }
            }
        }

        /// <summary>
        /// Builds a parameterised SQL SELECT based on the current filter values,
        /// aggregates Male/Female population per age group, then serialises the
        /// result into JSON hidden fields consumed by the Chart.js script.
        /// </summary>
        private void LoadChartData()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["GraphicViewDB"].ConnectionString;

            // ── Build WHERE clause from selected filters ───────────────────
            var whereParts = new List<string>();
            var sqlParams  = new List<SqlParameter>();

            string year   = ddlYear.SelectedValue;
            string region = ddlRegion.SelectedValue;
            string sex    = ddlSex.SelectedValue;   // "B", "M", or "F"

            if (!string.IsNullOrEmpty(year))
            {
                whereParts.Add("[Year] = @Year");
                sqlParams.Add(new SqlParameter("@Year", SqlDbType.Int) { Value = int.Parse(year) });
            }

            if (!string.IsNullOrEmpty(region))
            {
                whereParts.Add("Region = @Region");
                sqlParams.Add(new SqlParameter("@Region", SqlDbType.VarChar, 100) { Value = region });
            }

            if (sex == "M" || sex == "F")
            {
                whereParts.Add("Sex = @Sex");
                sqlParams.Add(new SqlParameter("@Sex", SqlDbType.Char, 1) { Value = sex });
            }

            string where = whereParts.Count > 0
                ? "WHERE " + string.Join(" AND ", whereParts)
                : string.Empty;

            // ── SQL: aggregate male / female per age group ─────────────────
            // The CASE expression orders by the standard age-group sequence so
            // the pyramid is always displayed youngest-to-oldest (bottom-to-top).
            string sql = @"
SELECT
    AgeGroup,
    ISNULL(SUM(CASE WHEN Sex = 'M' THEN Population ELSE 0 END), 0) AS Male,
    ISNULL(SUM(CASE WHEN Sex = 'F' THEN Population ELSE 0 END), 0) AS Female
FROM dbo.PopulationData
" + where + @"
GROUP BY AgeGroup
ORDER BY
    CASE AgeGroup
        WHEN '0-4'   THEN  1
        WHEN '5-9'   THEN  2
        WHEN '10-14' THEN  3
        WHEN '15-19' THEN  4
        WHEN '20-24' THEN  5
        WHEN '25-29' THEN  6
        WHEN '30-34' THEN  7
        WHEN '35-39' THEN  8
        WHEN '40-44' THEN  9
        WHEN '45-49' THEN 10
        WHEN '50-54' THEN 11
        WHEN '55-59' THEN 12
        WHEN '60-64' THEN 13
        WHEN '65-69' THEN 14
        WHEN '70-74' THEN 15
        WHEN '75-79' THEN 16
        WHEN '80+'   THEN 17
        ELSE 99
    END";

            // ── Execute and collect results ────────────────────────────────
            var ageGroups  = new List<string>();
            var maleData   = new List<long>();
            var femaleData = new List<long>();
            var tableRows  = new List<SummaryRow>();

            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddRange(sqlParams.ToArray());

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string ag = rdr["AgeGroup"].ToString();
                            long   m  = Convert.ToInt64(rdr["Male"]);
                            long   f  = Convert.ToInt64(rdr["Female"]);

                            ageGroups.Add(ag);
                            maleData.Add(m);
                            femaleData.Add(f);
                            tableRows.Add(new SummaryRow
                            {
                                AgeGroup = ag,
                                Male     = m,
                                Female   = f,
                                Total    = m + f
                            });
                        }
                    }
                }
            }

            // ── Serialise to JSON for the Chart.js script ──────────────────
            // MaxJsonLength is raised to Int32.MaxValue so the serialiser does not
            // throw for datasets that exceed the default 2 MB limit.
            var js = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            hfAgeGroups.Value  = js.Serialize(ageGroups);
            hfMaleData.Value   = js.Serialize(maleData);
            hfFemaleData.Value = js.Serialize(femaleData);
            hfSexFilter.Value  = sex;

            // ── Build a descriptive chart title ───────────────────────────
            var titleParts = new List<string> { "Population Pyramid" };
            if (!string.IsNullOrEmpty(year))   titleParts.Add("Year: "   + year);
            if (!string.IsNullOrEmpty(region)) titleParts.Add("Region: " + region);
            if (sex == "M") titleParts.Add("(Male only)");
            if (sex == "F") titleParts.Add("(Female only)");
            hfChartTitle.Value = string.Join(" · ", titleParts);

            // ── Show / hide panels ─────────────────────────────────────────
            if (ageGroups.Count == 0)
            {
                ShowInfo("No data found for the selected filters.  "
                    + "Try different options or ensure the database is populated.");
                pnlPlaceholder.Visible = true;
                pnlChart.Visible       = false;
                pnlSummary.Visible     = false;
            }
            else
            {
                lblMessage.Visible     = false;
                pnlPlaceholder.Visible = false;
                pnlChart.Visible       = true;
                pnlSummary.Visible     = true;

                // Bind summary table
                gvSummary.DataSource = tableRows;
                gvSummary.DataBind();
            }
        }

        // ── Message helpers ────────────────────────────────────────────────

        private void ShowInfo(string text)
        {
            lblMessage.Text      = text;
            lblMessage.CssClass  = "message-info";
            lblMessage.Visible   = true;
        }

        private void ShowWarning(string text)
        {
            lblMessage.Text      = text;
            lblMessage.CssClass  = "message-warning";
            lblMessage.Visible   = true;
        }

        // ── Nested helper DTO ─────────────────────────────────────────────

        private sealed class SummaryRow
        {
            public string AgeGroup { get; set; }
            public long   Male     { get; set; }
            public long   Female   { get; set; }
            public long   Total    { get; set; }
        }
    }
}
