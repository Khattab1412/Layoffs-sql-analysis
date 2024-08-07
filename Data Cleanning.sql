-- Switch to the world_layoffs database
USE world_layoffs;

-- Disable SQL safe updates
SET SQL_SAFE_UPDATES = 0;

-- Select all records from the layoffs table
SELECT * 
FROM layoffs;

-- Drop the layoffs_staging table if it exists (commented out)
-- DROP TABLE layoffs_staging;

-- Create a new table called layoffs_staging with the same structure as the layoffs table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Select all records from the newly created layoffs_staging table
SELECT * 
FROM layoffs_staging;

-- Insert all records from the layoffs table into the layoffs_staging table
INSERT INTO layoffs_staging 
SELECT * 
FROM layoffs;

-- Select all records from the layoffs_staging table to verify the insertion
SELECT * 
FROM layoffs_staging;

-- Remove duplicates using a Common Table Expression (CTE)
WITH DuplicateRows AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
  FROM layoffs_staging
)
-- Select all records with row numbers greater than 1 (these are duplicates)
SELECT * 
FROM DuplicateRows 
WHERE row_num > 1;

-- Create a new table called layoffs_staging2 with specified columns
CREATE TABLE `layoffs_staging2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` BIGINT DEFAULT NULL,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Select all records from the newly created layoffs_staging2 table
SELECT * 
FROM layoffs_staging2;

-- Insert all records from the layoffs_staging table into layoffs_staging2 with row numbers for duplicates
INSERT INTO layoffs_staging2 
SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num
FROM layoffs_staging;

-- Select rows with row numbers greater than 1 to verify duplicates (optional)
SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1;

-- Delete rows with row numbers greater than 1 (these are duplicates)
DELETE 
FROM layoffs_staging2 
WHERE row_num > 1;

-- Verify deletion by selecting rows with row numbers greater than 1 (optional)
SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1;

-- Select all records from layoffs_staging2 for verification (optional)
SELECT * 
FROM layoffs_staging2;

-- Standardizing Data

-- Trim whitespace from the company column and select the results
SELECT company, TRIM(company) 
FROM layoffs_staging2;

-- Update the company column to remove leading and trailing whitespace
UPDATE layoffs_staging2 
SET company = TRIM(company);

-- Select the trimmed company column to verify the update
SELECT company 
FROM layoffs_staging2;


-- Fixing distinct industries

-- Select distinct industries from layoffs_staging2 and order them alphabetically
SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1;

-- Select all records from layoffs_staging2 where the industry starts with 'Crypto'
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Update the industry column to 'Crypto' where the industry starts with 'Crypto'
UPDATE layoffs_staging2  
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Select all records from layoffs_staging2 where the industry is 'Crypto' to verify the update
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


-- Handling distinct locations

-- Select all country values from layoffs_staging2
SELECT country 
FROM layoffs_staging2;

-- Select country values and trim trailing periods from them, then order the results
SELECT country, TRIM(TRAILING '.' FROM country) 
FROM layoffs_staging2
ORDER BY 1;

-- Update the country column by trimming trailing periods
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Formatting the date

-- Select the date column and convert it to the desired format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') 
FROM layoffs_staging2;

-- Update the date column by converting it to the desired format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify the date column to be of DATE type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
-- Handling null values

-- Select all records where both total_laid_off and percentage_laid_off are null
SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Select distinct records where industry is null or empty
SELECT DISTINCT * 
FROM layoffs_staging2 
WHERE industry IS NULL 
OR industry = '';

-- Select the industry for the company 'Airbnb'
SELECT industry 
FROM layoffs_staging2 
WHERE company = 'Airbnb';

-- Update the industry column to NULL where it is currently empty
UPDATE layoffs_staging2 
SET industry = NULL 
WHERE industry = '';

-- Select industry values where one industry is NULL and the other is not for the same company
SELECT T1.industry, T2.industry 
FROM layoffs_staging2 T1 
JOIN layoffs_staging2 T2 
  ON T1.company = T2.company 
WHERE T1.industry IS NULL 
AND T2.industry IS NOT NULL;

-- Update the industry column with non-null values for the same company where the industry is currently null
UPDATE layoffs_staging2 T1 
JOIN layoffs_staging2 T2 
  ON T1.company = T2.company 
SET T1.industry = T2.industry 
WHERE T1.industry IS NULL 
AND T2.industry IS NOT NULL;

-- Select all records where both total_laid_off and percentage_laid_off are null
SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Delete records where both total_laid_off and percentage_laid_off are null
DELETE 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Select all records from layoffs_staging2 to verify the deletion
SELECT * 
FROM layoffs_staging2;

-- Drop the row_num column from the table
ALTER TABLE layoffs_staging2 
DROP COLUMN row_num;

-- Select all records from layoffs_staging2 to verify the structure
SELECT * 
FROM layoffs_staging2;
