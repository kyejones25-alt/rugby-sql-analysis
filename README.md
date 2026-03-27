# Six Nations Rugby Performance Analysis (SQL & Power BI)

## Overview
End-to-end analytics project analyzing **25 years of Six Nations rugby data** (2000–2025) and **150+ years of international rugby results** (1871–2024). Raw match data was cleaned and transformed in SQL, analyzed through 18 queries of increasing complexity, and visualized in a Power BI dashboard.

## Tools & Technologies
- **SQL (SQLite)** — data cleaning, transformation, and analysis
- **DB Browser for SQLite** — database management
- **Power BI** — interactive dashboard and data visualization

## Datasets
| Dataset | Records | Source |
|---------|---------|--------|
| Six Nations Results (2000–2025) | 390 matches | [Kaggle](https://www.kaggle.com/datasets/simfour/rugby-6-nations-results-2000-2024) |
| International Rugby Results (1871–2024) | 2,783 matches | [Kaggle](https://www.kaggle.com/datasets/lylebegbie/international-rugby-union-results-from-18712022) |

## Project Structure
```
rugby-sql-analysis/
├── README.md
├── rugby_analysis.db                  ← SQLite database (ready to query)
├── sql/
│   ├── 01_data_cleaning.sql           ← Data prep, quality checks, calculated fields
│   ├── 02_core_analysis.sql           ← 10 queries: wins, scoring, home advantage, trends
│   └── 03_advanced_analysis.sql       ← 8 queries: JOINs, CTEs, window functions
├── data/
│   ├── six_nations_results.csv        ← Raw Six Nations data
│   ├── international_results.csv      ← Raw international results
│   └── data_six_nations_clean.csv     ← Cleaned dataset with calculated fields
└── dashboard/
    └── six_nations_dashboard.pbix     ← Power BI dashboard file
```

## SQL Skills Demonstrated

### File 01 — Data Cleaning & Preparation
- Created clean working tables from raw imports
- Validated data quality: checked for NULLs in scores and team names
- Verified team name consistency across datasets
- Added calculated columns: `Winner` (match result) and `PointDiff` (score margin)

### File 02 — Core Analysis (10 Queries)
| # | Analysis | Technique |
|---|----------|-----------|
| 1 | Total wins by team | GROUP BY, COUNT, WHERE |
| 2 | Average points scored by team | UNION ALL, AVG, subquery |
| 3 | Team win rate | CASE WHEN inside SUM, calculated percentages |
| 4 | Home advantage rate | Aggregate CASE expression |
| 5 | Closest matches | ORDER BY ASC, LIMIT |
| 6 | Largest winning margins | ORDER BY DESC, LIMIT |
| 7 | Scoring trends by year | GROUP BY year, AVG |
| 8 | Competitiveness over time | AVG(PointDiff) by year |
| 9 | Home vs away scoring by team | UNION ALL pivot, GROUP BY |
| 10 | Draw frequency | Conditional aggregation |

### File 03 — Advanced Analysis (8 Queries)
| # | Analysis | Technique |
|---|----------|-----------|
| 11 | Six Nations vs international win % | **Two CTEs + INNER JOIN** across tables |
| 12 | Head-to-head rivalry records | Multi-column GROUP BY |
| 13 | Tournament rankings by year | **RANK() window function + PARTITION BY** |
| 14 | Year-over-year momentum | **LAG() window function** |
| 15 | Cumulative wins over time | **SUM() OVER (ROWS UNBOUNDED PRECEDING)** |
| 16 | Longest win streaks | **ROW_NUMBER gap detection technique** |
| 17 | Champion vs non-champion profile | **Chained CTEs + RANK()** |
| 18 | Win streak momentum effect | **LAG() for sequential analysis** |

## Key Findings

- **Ireland** recorded the highest number of wins, narrowly ahead of England and France
- **England** achieved the highest average points scored per match
- **Home advantage** is real — home teams win approximately 59% of matches
- **Momentum matters** — teams coming off a win have a significantly higher chance of winning their next match
- Match competitiveness varies significantly, with scoring trends increasing in recent years
- Ireland, England, and France form a dominant top tier, consistently outperforming the remaining teams

## Power BI Dashboard
The dashboard includes:
- Total wins by team
- Average points scored by team
- Home win rate analysis
- Match competitiveness breakdown
- Scoring trends over time
- Top 10 largest winning margins

*Open `dashboard/six_nations_dashboard.pbix` in Power BI Desktop to interact with the dashboard.*

## Author
**Kye Jones** — MS in IT Management (Data Analytics, 4.0 GPA), Central Washington University
- LinkedIn: [linkedin.com/in/kye-jones-1744a3225](https://www.linkedin.com/in/kye-jones-1744a3225)
- GitHub: [github.com/kyejones25-alt](https://github.com/kyejones25-alt)
