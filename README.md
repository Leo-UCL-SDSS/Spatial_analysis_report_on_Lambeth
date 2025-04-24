# README for Spatial Analysis of Lambeth Project (Data Analysis Assessment II)

## Project Overview

This repository contains the R-based spatial analysis and reporting for the Data Analysis Assessment II (POLS0010). It explores unemployment patterns and their relationship with educational deprivation across Lambeth’s LSOAs using 2021 Census and IMD 2019 data. Analyses include spatial clustering (Moran’s I & LISA) and Geographically Weighted Regression (GWR).

---

## Files Included

1. **Data analysis assessment II.Rmd**  
   **Description:** Quarto (R Markdown) source file with narrative, code chunks, and embedded figures for the full analysis and report.

2. **Data prep.R**  
   **Description:** R script containing data loading, cleaning, and preprocessing steps (census import, shapefile merging, OA→LSOA aggregation).

3. **data analysis assessment 2.R**  
   **Description:** R script with additional analyses (Moran’s I tests, neighbor definitions, quadrant classification, scatter plots).

4. **Data-analysis-assessment-II.html**  
   **Description:** Rendered HTML report generated from `Data analysis assessment II.Rmd`. Provides a web-viewable version of the full analysis.

5. **Spatial analysis report on Lambeth.pdf**  
   **Description:** Final PDF export of the report. Suitable for offline reading or formal submission.

---

## How to Reproduce the Analysis

1. **Pre-requisites:**  
   - R (>= 4.0) and RStudio (optional)  
   - Install required packages:  
     ```r
     install.packages(c(
       "sf", "spdep", "spgwr", "tmap", "dplyr",
       "ggplot2", "gridExtra", "leaflet", "tidyverse"
     ))
     ```

2. **Run Data Prep:**  
   - Open `Data prep.R` in RStudio (or R console) and execute to produce the cleaned and merged spatial dataset.

3. **Run Analysis Scripts:**  
   - Execute `data analysis assessment 2.R` to compute Moran’s I, LISA clusters, GWR models, and generate plots.

4. **Render the Report:**  
   - Open `Data analysis assessment II.Rmd` and click **Knit** (or use `quarto render`) to generate the HTML and PDF outputs.  
   ```bash
   quarto render "Data analysis assessment II.Rmd"
   ```

5. **View Outputs:**  
   - Open `Data-analysis-assessment-II.html` in your browser or read `Spatial analysis report on Lambeth.pdf` for the final documented results.

---

## Project Structure

```plaintext
├── Data prep.R                    # Data loading & preprocessing
├── data analysis assessment 2.R   # Spatial stats & modeling scripts
├── Data analysis assessment II.Rmd # R Markdown source for report
├── Data-analysis-assessment-II.html # HTML report output
├── Spatial analysis report on Lambeth.pdf # Final PDF report
└── README.md                      # This file
```

---

## Contact

For questions or feedback, please reach out:  
**Name:Haofan Liao
**Email:** stnzhl4@ucl.ac.uk
**GitHub:** https://github.com/Leo-UCL-SDSS

