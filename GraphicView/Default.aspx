<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="GraphicView.Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>GraphicView – Age/Sex Population Pyramid</title>
    <link href="Content/Site.css" rel="stylesheet" />
    <%-- Chart.js loaded from CDN; replace with a local copy for offline use --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
</head>
<body>

    <%-- ════════════════════════════════════════════════════════
         Header
    ════════════════════════════════════════════════════════ --%>
    <header class="app-header">
        <h1>GraphicView</h1>
        <p>Population Age/Sex Pyramid</p>
    </header>

    <main class="main-container">
        <form id="form1" runat="server">

            <%-- ═══════════════════════════════════════════════
                 Filter panel – options that drive the SQL query
            ═══════════════════════════════════════════════ --%>
            <div class="filter-panel">

                <div class="filter-group">
                    <label for="ddlYear">Year</label>
                    <asp:DropDownList ID="ddlYear" runat="server" CssClass="form-select">
                        <asp:ListItem Text="— All Years —" Value="" />
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label for="ddlRegion">Region</label>
                    <asp:DropDownList ID="ddlRegion" runat="server" CssClass="form-select">
                        <asp:ListItem Text="— All Regions —" Value="" />
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label for="ddlSex">Show</label>
                    <asp:DropDownList ID="ddlSex" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Both sexes" Value="B" Selected="True" />
                        <asp:ListItem Text="Male only"  Value="M" />
                        <asp:ListItem Text="Female only" Value="F" />
                    </asp:DropDownList>
                </div>

                <asp:Button ID="btnShow" runat="server" Text="Show Pyramid"
                    CssClass="btn-show" OnClick="btnShow_Click" />

            </div>

            <%-- ═══════════════════════════════════════════════
                 Message area
            ═══════════════════════════════════════════════ --%>
            <div class="message-area">
                <asp:Label ID="lblMessage" runat="server" Visible="false" />
            </div>

            <%-- ═══════════════════════════════════════════════
                 Chart panel
            ═══════════════════════════════════════════════ --%>
            <div class="chart-panel">
                <asp:Panel ID="pnlPlaceholder" runat="server" CssClass="chart-placeholder">
                    <span class="icon">📊</span>
                    <span>Select your options above and click <strong>Show Pyramid</strong>.</span>
                </asp:Panel>

                <asp:Panel ID="pnlChart" runat="server" Visible="false" CssClass="chart-wrapper">
                    <canvas id="pyramidChart"></canvas>
                </asp:Panel>
            </div>

            <%-- ═══════════════════════════════════════════════
                 Summary data table (shown after chart loads)
            ═══════════════════════════════════════════════ --%>
            <asp:Panel ID="pnlSummary" runat="server" Visible="false" CssClass="summary-panel">
                <h2>Data Summary</h2>
                <asp:GridView ID="gvSummary" runat="server"
                    CssClass="data-table"
                    AutoGenerateColumns="false"
                    GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="AgeGroup"  HeaderText="Age Group" />
                        <asp:BoundField DataField="Male"      HeaderText="Male"      ItemStyle-CssClass="td-male"
                            DataFormatString="{0:N0}" HtmlEncode="false" />
                        <asp:BoundField DataField="Female"    HeaderText="Female"    ItemStyle-CssClass="td-female"
                            DataFormatString="{0:N0}" HtmlEncode="false" />
                        <asp:BoundField DataField="Total"     HeaderText="Total"     ItemStyle-CssClass="td-total"
                            DataFormatString="{0:N0}" HtmlEncode="false" />
                    </Columns>
                </asp:GridView>
            </asp:Panel>

            <%-- Hidden fields carry JSON data to the client-side chart script --%>
            <asp:HiddenField ID="hfAgeGroups"  runat="server" />
            <asp:HiddenField ID="hfMaleData"   runat="server" />
            <asp:HiddenField ID="hfFemaleData" runat="server" />
            <asp:HiddenField ID="hfChartTitle" runat="server" />
            <asp:HiddenField ID="hfSexFilter"  runat="server" />

        </form>
    </main>

    <footer class="app-footer">
        GraphicView &copy; <%= DateTime.Now.Year %> &nbsp;|&nbsp; Age/Sex Population Pyramid
    </footer>

    <%-- ════════════════════════════════════════════════════════
         Chart.js pyramid initialisation
         Reads the JSON arrays that the code-behind serialised
         into the hidden fields and builds a horizontal bar chart
         where Male bars extend to the left (negative x) and
         Female bars extend to the right (positive x).
    ════════════════════════════════════════════════════════ --%>
    <script>
    (function () {
        /* Retrieve server-rendered data */
        function hf(id) {
            var el = document.getElementById(id);
            return el ? el.value : '';
        }

        var ageGroups  = JSON.parse(hf('<%= hfAgeGroups.ClientID  %>') || '[]');
        var maleRaw    = JSON.parse(hf('<%= hfMaleData.ClientID   %>') || '[]');
        var femaleRaw  = JSON.parse(hf('<%= hfFemaleData.ClientID %>') || '[]');
        var chartTitle = hf('<%= hfChartTitle.ClientID %>') || 'Population Pyramid';
        var sexFilter  = hf('<%= hfSexFilter.ClientID  %>') || 'B';

        if (ageGroups.length === 0) { return; }   /* nothing to draw yet */

        /* Male values are negated so they appear on the left side */
        var maleNeg = maleRaw.map(function (v) { return -Math.abs(v); });

        /* Build the datasets array depending on the sex filter */
        var datasets = [];
        if (sexFilter === 'B' || sexFilter === 'M') {
            datasets.push({
                label: 'Male',
                data: (sexFilter === 'M') ? maleRaw : maleNeg, /* positive when shown alone */
                backgroundColor: 'rgba(30, 136, 229, 0.80)',
                borderColor:     'rgba(21,  101, 192, 1)',
                borderWidth: 1,
                borderSkipped: false
            });
        }
        if (sexFilter === 'B' || sexFilter === 'F') {
            datasets.push({
                label: 'Female',
                data: femaleRaw,
                backgroundColor: 'rgba(229, 57, 53, 0.80)',
                borderColor:     'rgba(183, 28, 28, 1)',
                borderWidth: 1,
                borderSkipped: false
            });
        }

        var ctx = document.getElementById('pyramidChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ageGroups,
                datasets: datasets
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: {
                        display: true,
                        text: chartTitle,
                        font: { size: 15, weight: 'bold' },
                        color: '#1a237e',
                        padding: { bottom: 16 }
                    },
                    legend: {
                        position: 'top',
                        labels: { font: { size: 13 } }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                /* Always show absolute value in tooltips */
                                return context.dataset.label + ': '
                                    + Math.abs(context.parsed.x).toLocaleString();
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        stacked: false,
                        ticks: {
                            callback: function (value) {
                                return Math.abs(value).toLocaleString();
                            },
                            font: { size: 12 }
                        },
                        title: {
                            display: true,
                            text: 'Population',
                            font: { size: 13 }
                        }
                    },
                    y: {
                        stacked: false,
                        ticks: { font: { size: 12 } },
                        title: {
                            display: true,
                            text: 'Age Group',
                            font: { size: 13 }
                        }
                    }
                }
            }
        });
    }());
    </script>

</body>
</html>
