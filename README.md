# 🎨 Museum & Art Gallery Data Analysis - SQL Project

##  Project Overview

This project involves comprehensive data analysis using SQL on a museum and art gallery dataset. The primary objective is to derive actionable insights regarding museum operations, artists, paintings, pricing, and related entities. It covers data cleaning, exploration, and business-specific analytical queries.

---

##  Dataset Tables

The project uses the following tables:

* `artist`: Contains details about artists (e.g., full name, nationality).
* `canvas_size`: Maps size IDs to canvas labels.
* `image_link`: Contains image references for artworks.
* `museum`: Holds information about museums including location.
* `museum_hours`: Captures daily opening hours of museums.
* `product_size`: Contains pricing and size details for artworks.
* `subject`: Lists subjects/themes of each artwork.
* `work`: Central table with details about each artwork.

---

##  Key Business Insights

###  Museum Operations

* **Museums Open on Sunday & Monday**: Identified museums open on both days using various SQL techniques.
* **Longest Daily Operating Hours**: Found museums open for the longest duration on any single day.
* **Museums Open Every Day**: Counted museums operating all 7 days.
* **Invalid Entries**: Detected and removed data anomalies like duplicate museum hours and numeric city names.

###  Artwork & Artist Analysis

* **Unsold Artworks**: Fetched paintings not displayed in any museum.
* **Museums with No Artworks**: Identified museums with no associated paintings.
* **Price Analysis**:

  * Paintings with sale prices higher than regular prices.
  * Paintings with asking price less than 50% of regular price.
  * Most expensive and least expensive paintings with artist and museum details.
* **Popular Subjects**: Top 10 most frequent subjects/themes across paintings.
* **Popular Artists**: Ranked artists by number of paintings.
* **Popular Museums**: Museums with the most paintings.
* **Artists Across Countries**: Artists whose work is displayed internationally.

###  Canvas Insights

* **Most Expensive Canvas Size**: Identified the canvas size with the highest sale price.
* **Least Popular Sizes**: Displayed bottom 3 least used canvas sizes.

---

##  Data Cleaning

Handled duplicate records in:

* `work`
* `product_size`
* `subject`
* `image_link`

Also removed invalid entries in `museum_hours` and cities starting with numeric values.

---

##  SQL Techniques Used

* `JOIN`, `GROUP BY`, `HAVING`, `RANK`, `DENSE_RANK`
* Window functions (`ROW_NUMBER`, `RANK`)
* Common Table Expressions (CTEs)
* Subqueries and correlated subqueries
* `EXTRACT`, `TO_TIMESTAMP`, `DELETE USING ROW_NUMBER`

---

##  Use Case

This analysis can support:

* Art marketplace platforms to understand pricing strategies.
* Museums in optimizing operations and exhibits.
* Art historians in identifying popular trends and artist reach.
* Data cleaning and standardization in ETL processes.

---

##  Tools Used

* PostgreSQL (or any ANSI-compliant SQL engine)
* DB tools like pgAdmin, DBeaver, or SQL Workbench for execution

---

##  Project Status

Completed. All queries executed successfully with validated outputs. Dataset cleaned and optimized for analysis.
