-- Data Cleaning


SELECT *
FROM world_layoffs.layoffs;

-- 1. Check for duplicates and Remove Duplicates
-- 2. Standardize the Data and fix errors
-- 3. Null Values or blank values
-- 4. Remove Any Columns and Rows that are not needed for the analysis

CREATE TABLE layoffs_stagings
LIKE world_layoffs.layoffs;


INSERT layoffs_stagings
SELECT *
FROM world_layoffs.layoffs;

-- 1. First let's check for duplicates 

SELECT *
FROM layoffs_stagings;

-- Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagings;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagings
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_stagings
WHERE company = 'Casper';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagings
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_stagings2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_stagings2;

INSERT INTO layoffs_stagings2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_stagings;

SELECT *
FROM layoffs_stagings2
WHERE row_num > 1;

DELETE 
FROM layoffs_stagings2
WHERE row_num > 1;

SELECT *
FROM layoffs_stagings2;


-- 2. Standardize data :- Standardizing data means finding issues with your data and fixing it 

SELECT DISTINCT(company)
FROM layoffs_stagings2;

-- TRIM() is used to remove whitespace

SELECT DISTINCT(TRIM(company))
FROM layoffs_stagings2;

SELECT company, TRIM(company)
FROM layoffs_stagings2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- If we look at industry it looks like we have null, I also noticed Crypto has multiple different variations. We need to standardize that. Let's set alll to Crypto

SELECT DISTINCT industry
FROM layoffs_stagings2
ORDER BY 1;

SELECT *
FROM layoffs_stagings2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_stagings2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- now that's taken care of

SELECT DISTINCT industry
FROM layoffs_stagings2
ORDER BY industry;

SELECT DISTINCT country
FROM layoffs_stagings2
ORDER BY 1;

-- We need to look at the country column, Everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize it.

SELECT DISTINCT country
FROM layoffs_stagings2
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_stagings2
ORDER BY 1;

UPDATE layoffs_satgings2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'; 

SELECT DISTINCT country
FROM layoffs_stagings2
ORDER BY country;

-- Let's also fix the date columns

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_stagings2;

-- We can use str for date to update this field 

UPDATE layoffs_stagings2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the date type properly 

ALTER TABLE layoffs_stagings2
MODIFY COLUMN `date` DATE;

SELECT `date`
FROM layoffs_stagings2;

-- 3. Look at Null Values

-- The null values in total_laid_off, percentage_laid_off and funds_raised_millions all look normal. I dont think I want to change alter that
-- I like having them null because it makes it easier for calculations during the Exploratory Data Analysis(EDA) phase
-- There's nothing i want to change with the null values

SELECT *
FROM layoffs_stagings2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- We should set the blanks to nulls since those are typically easier to work with

UPDATE layoffs_stagings2
SET industry = NULL
WHERE industry = '';

-- Now if we check those are all null 

SELECT *
FROM layoffs_stagings2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_stagings2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_stagings2 t1
JOIN layoffs_stagings2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- We need to populate those nulls if possible

UPDATE layoffs_stagings2 t1
JOIN layoffs_stagings2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- If we check it looks like Bally's was the only one without a populated row to populate this null values 

SELECT *
FROM layoffs_stagings2
WHERE company LIKE 'Bally%';

-- 4. Remove any columns and Rows we need to remove

SELECT *
FROM layoffs_stagings2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use

DELETE 
FROM layoffs_stagings2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_stagings2
DROP COLUMN row_num;

SELECT *
FROM layoffs_stagings2;

-- Exploratory Data Analysis

SELECT *
FROM layoffs_stagings2;

SELECT MAX(total_laid_off)
FROM layoffs_stagings2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_stagings2;

SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_stagings2;

SELECT *
FROM layoffs_stagings2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_stagings2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies with the highest layoff

SELECT company, SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY company
ORDER BY 2 DESC
LIMIT 7;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_stagings2;

-- What is the total laid off of the industries?

SELECT industry, SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY industry
ORDER BY 2 DESC;

SELECT industry, ROUND(AVG(percentage_laid_off),2) AS Average_percentage_laid_off
FROM layoffs_stagings2
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry
ORDER BY Average_percentage_laid_off DESC;

-- What is the total laid off of each countries?

SELECT country, SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY country
ORDER BY 2 DESC;

SELECT country, ROUND(AVG(percentage_laid_off),2) AS Average_percentage_laid_off
FROM layoffs_stagings2
WHERE percentage_laid_off IS NOT NULL
GROUP BY country
ORDER BY Average_percentage_laid_off DESC;

SELECT company, industry, total_laid_off, percentage_laid_off
FROM layoffs_stagings2
ORDER BY total_laid_off DESC;

-- What is the total laid off for each year?

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- What is the total laid off of each stage?

SELECT stage, SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY stage
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_stagings2
WHERE stage IN ('Acquired', 'Post-IPO')
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_stagings2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Rolling total of Layoffs per Month

WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS Total_off
FROM layoffs_stagings2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, Total_off,
 SUM(Total_off) OVER(ORDER BY `MONTH`) AS Rolling_total
FROM Rolling_Total;

SELECT company, SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY company
ORDER BY 2 DESC;

-- Identify the top 5 companies with the highest percentage of layoffs.

SELECT company, ROUND(SUM(percentage_laid_off),2)
FROM layoffs_stagings2
WHERE percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC
LIMIT 5;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

SELECT company, funds_raised_millions, SUM(total_laid_off)
FROM layoffs_stagings2
WHERE funds_raised_millions IS NOT NULL
GROUP BY company, funds_raised_millions
ORDER BY SUM(total_laid_off) DESC;

SELECT AVG(funds_raised_millions) AS Average_funds_raised
FROM layoffs_stagings2
WHERE total_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL;

WITH significant_layoffs AS (
    SELECT *
    FROM layoffs_stagings2
    WHERE total_laid_off > 100  -- Filter companies with more than 100 layoffs
)
SELECT industry, SUM(total_laid_off) AS total_laid_off, ROUND(AVG(percentage_laid_off),2) AS Average_percentage_laid_off
FROM significant_layoffs
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Relationship between the amounts of funds raised and percentage laid off

SELECT funds_raised_millions, AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_stagings2
WHERE percentage_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL
GROUP BY funds_raised_millions
ORDER BY funds_raised_millions DESC;

-- Which sectors are most impacted by layoff
 
SELECT industry, COUNT(company) AS companies_affected, SUM(total_laid_off) AS total_laid_off
FROM layoffs_stagings2
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_laid_off DESC;

