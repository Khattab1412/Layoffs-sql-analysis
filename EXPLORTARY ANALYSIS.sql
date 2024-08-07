-- Exploratory Analysis: View all records from the staging table
SELECT *
FROM layoffs_staging2;

-- Highest layoff figures
-- Retrieve the maximum number of employees laid off and the highest percentage of layoffs
SELECT MAX(total_laid_off) AS max_laid_off, MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging2;

-- Companies with 100% layoffs
-- List companies where the percentage of layoffs is 100%, ordered by total layoffs in descending order
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Highest funds raised by companies with 100% layoffs
-- List companies with 100% layoffs, ordered by funds raised in millions in descending order
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total layoffs by company
-- Aggregate total layoffs for each company, ordered by total layoffs in descending order
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- Total layoffs by industry
-- Aggregate total layoffs for each industry, ordered by total layoffs in descending order
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Total layoffs by country
-- Aggregate total layoffs for each country, ordered by total layoffs in descending order
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Total layoffs by year
-- Aggregate total layoffs for each year, ordered by year in descending order
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year DESC;

-- Total layoffs by stage
-- Aggregate total layoffs for each stage, ordered by total layoffs in descending order
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Highest funds raised by any company
-- List all companies ordered by the amount of funds raised in millions in descending order
SELECT *
FROM layoffs_staging2
ORDER BY funds_raised_millions DESC;

-- Minimum and Maximum Dates
-- Retrieve the earliest and latest dates in the dataset
SELECT MIN(`date`) AS earliest_date, MAX(`date`) AS latest_date
FROM layoffs_staging2;

-- Total layoffs by month and year
-- Aggregate total layoffs by month, ordered by month in ascending order
SELECT SUBSTR(`date`,1,7) AS month, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTR(`date`,1,7) IS NOT NULL
GROUP BY month
ORDER BY month ASC;

-- Rolling sum of total layoffs by month
-- Calculate a rolling sum of total layoffs by month
WITH rolling_total AS (
  SELECT SUBSTR(`date`,1,7) AS month, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  WHERE SUBSTR(`date`,1,7) IS NOT NULL
  GROUP BY month
  ORDER BY month ASC
)
SELECT 
  month, 
  total_laid_off,
  SUM(total_laid_off) OVER (ORDER BY month) AS rolling_sum
FROM rolling_total;

-- Total layoffs by company per year
-- Aggregate total layoffs for each company by year, ordered by total layoffs in descending order
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_laid_off DESC;

-- Year with the highest layoffs for each company
-- Determine which year had the most layoffs for each company, ordered by the number of layoffs in descending order
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_laid_off DESC;

-- Rank companies by layoffs per year
-- Use CTEs to rank companies based on total layoffs per year
WITH company_year AS (
  SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(`date`)
), company_rank_per_year AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
  FROM company_year
  WHERE year IS NOT NULL
)
-- Retrieve top 5 companies per year based on layoffs
SELECT *
FROM company_rank_per_year
WHERE ranking <= 5;
