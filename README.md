# GraphicView

An ASP.NET Web Forms application that displays a **population age/sex pyramid** chart driven by data stored in a SQL Server database.  Filter dropdowns let you slice the data by **Year**, **Region**, and **Sex** before the chart is rendered.

---

## Features

| Feature | Details |
|---------|---------|
| **Age/Sex Pyramid** | Horizontal bar chart (Chart.js 4) – male bars grow to the left, female bars grow to the right |
| **Filter options** | Year, Region, and Sex dropdowns change the underlying SQL `SELECT` query |
| **Data summary** | A sortable table below the chart shows Male / Female / Total per age group |
| **SQL Server back-end** | One table (`dbo.PopulationData`) with a configurable connection string in `web.config` |

---

## Prerequisites

| Requirement | Version |
|-------------|---------|
| .NET Framework | 4.7.2 or later |
| Visual Studio | 2019 / 2022 (any edition) |
| SQL Server | 2016 or later (Express is fine) |
| IIS / IIS Express | bundled with Visual Studio |

---

## Quick Start

### 1 – Create the database

Open **SQL Server Management Studio** (or `sqlcmd`) and run:

```sql
CREATE DATABASE GraphicViewDB;
GO
```

Then execute the full setup script which creates the table, indexes, and sample data:

```
Sql\CreateDatabase.sql
```

### 2 – Configure the connection string

Edit `GraphicView\web.config` and update the `GraphicViewDB` entry:

```xml
<!-- Windows Authentication (default) -->
<add name="GraphicViewDB"
     connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=GraphicViewDB;Integrated Security=True"
     providerName="System.Data.SqlClient" />
```

Replace `.\SQLEXPRESS` with your SQL Server instance name.  If you use SQL Server Authentication, use Option B in the comment block.

### 3 – Open and run in Visual Studio

1. Open `GraphicView.sln`.
2. Set **GraphicView** as the start-up project.
3. Press **F5** (IIS Express) or deploy to a local IIS site.
4. The browser opens `Default.aspx`.

### 4 – Use the pyramid

1. Choose a **Year** and/or **Region** from the dropdowns (leave blank to include all values).
2. Choose which **sex** to display: *Both*, *Male only*, or *Female only*.
3. Click **Show Pyramid** — the chart and data summary update immediately.

---

## Project Structure

```
GraphicView/
├── GraphicView.sln                 ← Visual Studio solution
├── Sql/
│   └── CreateDatabase.sql          ← Schema + sample data
└── GraphicView/
    ├── GraphicView.csproj
    ├── web.config                  ← Connection string here
    ├── Global.asax / .cs
    ├── Default.aspx                ← Main page (chart + filters)
    ├── Default.aspx.cs             ← Code-behind (SQL query, JSON serialisation)
    ├── Default.aspx.designer.cs
    ├── Properties/
    │   └── AssemblyInfo.cs
    └── Content/
        └── Site.css                ← Page styles
```

---

## Database Schema

```sql
CREATE TABLE dbo.PopulationData
(
    Id         INT          IDENTITY PRIMARY KEY,
    AgeGroup   VARCHAR(10)  NOT NULL,   -- '0-4', '5-9', … '80+'
    Sex        CHAR(1)      NOT NULL,   -- 'M' = Male, 'F' = Female
    Population INT          NOT NULL DEFAULT 0,
    Year       INT          NOT NULL,
    Region     VARCHAR(100) NOT NULL DEFAULT 'National'
);
```

Add rows for any combination of Age Group, Sex, Year, and Region; the application picks up new values automatically in the filter dropdowns.

---

## Extending the Application

* **Add a new filter** – add a column to `PopulationData`, bind a new `DropDownList` in `Default.aspx`, and add the corresponding `WHERE` clause parameter in `Default.aspx.cs → LoadChartData()`.
* **Change chart colours** – edit the `backgroundColor` properties in the `<script>` block at the bottom of `Default.aspx`.
* **Swap Chart.js for a server-side chart** – replace the hidden-field / JavaScript approach with `System.Web.UI.DataVisualization.Charting` (requires the charting NuGet package).
