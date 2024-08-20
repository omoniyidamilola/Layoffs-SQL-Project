# Layoffs-SQL-Project

![](layoff_image.jpeg)

## Introduction 

The global economic landscape has been profoundly affected by the COVID-19 pandemic, leading to significant challenges for various industries, particularly the tech sector. As consumer spending slowed and central banks raised interest rates, the economic environment became increasingly uncertain. Many tech firms, facing these financial pressures and the strengthening of the U.S. dollar abroad, have resorted to layoffs as a means to navigate the downturn.

This project analyzes a dataset of tech layoffs from the onset of the pandemic in 2019 to the present. The data offers insights into how these companies have responded to the economic crisis, highlighting trends in layoffs across different industries, countries, and stages of company growth. By exploring this data, we aim to understand the broader impact of the economic slowdown on the tech sector and identify patterns that may inform future business strategies.

## Aim of the Project

This project analyzes a dataset of global layoffs, focusing on identifying trends, patterns, and insights into the companies, industries, and stages most affected by layoffs. The goal is to draw actionable insights that could inform decision making for stakeholders.


## About the Dataset

Company :
Name of the company

Location :
Location of company headquarters

Industry :
Industry of the company

Total_laid_off :
Number of employees laid off

Percentage_laid_off :
Percentage of employees laid off

Date :
Date of layoff

Stage :
Stage of funding

Country :
Country

Funds_raised :
Funds raised by the company (in Millions $)

## DATA CLEANING


SELECT *

FROM world_layoffs.layoffs;

![](/Layout_DC/DC1.png)

#### 1. Check for duplicates and Remove Duplicates

#### 2. Standardize the Data and fix errors

#### 3. Null Values or blank values

#### 4. Remove Any Columns and Rows that are not needed for the analysis

#### Creating Layoffs_staging Table

CREATE TABLE layoffs_stagings

LIKE world_layoffs.layoffs;


INSERT layoffs_stagings

SELECT *

FROM world_layoffs.layoffs;

**-- 1. First let's check for duplicates** 

SELECT *

FROM layoffs_stagings;

#### Remove Duplicates

SELECT *,

ROW_NUMBER() OVER(

PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 

'date', stage, country, funds_raised_millions) AS row_num

FROM layoffs_stagings;

![](/Layout_DC/DC2.png)

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

![](/Layout_DC/DC3.png)

SELECT *

FROM layoffs_stagings

WHERE company = 'Casper';

![](/Layout_DC/DC4.png)

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


#### 2. Standardize data :- Standardizing data means finding issues with your data and fixing it 

SELECT DISTINCT(company)

FROM layoffs_stagings2;

**-TRIM() is used to remove whitespace**

SELECT DISTINCT(TRIM(company))

FROM layoffs_stagings2;

![](/Layout_DC/DC5.png)

SELECT company, TRIM(company)

FROM layoffs_stagings2;

![](/Layout_DC/DC6.png)

UPDATE layoffs_staging2

SET company = TRIM(company);

**-- If we look at industry it looks like we have null, I also noticed Crypto has multiple different variations. We need to standardize that. Let's set alll to Crypto**

SELECT DISTINCT industry

FROM layoffs_stagings2

ORDER BY 1;

SELECT *

FROM layoffs_stagings2

WHERE industry LIKE 'Crypto%';

![](/Layout_DC/DC7.png)

UPDATE layoffs_stagings2

SET industry = 'Crypto'

WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

**- now that's taken care of**

SELECT DISTINCT industry

FROM layoffs_stagings2

ORDER BY industry;

SELECT DISTINCT country

FROM layoffs_stagings2

ORDER BY 1;

**- We need to look at the country column, Everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize it.**

SELECT DISTINCT country

FROM layoffs_stagings2

WHERE country LIKE 'United States%'

ORDER BY 1;

![](/Layout_DC/DC8.png)

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)

FROM layoffs_stagings2

ORDER BY 1;

UPDATE layoffs_satgings2

SET country = TRIM(TRAILING '.' FROM country)

WHERE country LIKE 'United States%'; 

SELECT DISTINCT country

FROM layoffs_stagings2

ORDER BY country;

**-- Let's also fix the date columns**

SELECT `date`,

STR_TO_DATE(`date`,'%m/%d/%Y')

FROM layoffs_stagings2;

**-- We can use STR for date to update this field**

UPDATE layoffs_stagings2

SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

**-- now we can convert the date type properly**

ALTER TABLE layoffs_stagings2

MODIFY COLUMN `date` DATE;

SELECT `date`

FROM layoffs_stagings2;

![](/Layout_DC/DC9.png)

**-- 3. Look at Null Values**

**-- The null values in total_laid_off, percentage_laid_off and funds_raised_millions all look normal. I dont think I want to change that**

**-- I like having them null because it makes it easier for calculations during the Exploratory Data Analysis(EDA) phase**

SELECT *

FROM layoffs_stagings2

WHERE total_laid_off IS NULL

AND percentage_laid_off IS NULL;

**-- We should set the blanks to nulls since those are typically easier to work with**

UPDATE layoffs_stagings2

SET industry = NULL

WHERE industry = '';

**-- Now if we check those are all null**

SELECT *

FROM layoffs_stagings2

WHERE industry IS NULL

OR industry = '';

SELECT *

FROM layoffs_stagings2

WHERE company = 'Airbnb';

![](/Layout_DC/DC10.png)

SELECT t1.industry, t2.industry

FROM layoffs_stagings2 t1

JOIN layoffs_stagings2 t2
   
    ON t1.company = t2.company

WHERE (t1.industry IS NULL OR t1.industry = '')

AND t2.industry IS NOT NULL;

**-- We need to populate those nulls if possible**

UPDATE layoffs_stagings2 t1

JOIN layoffs_stagings2 t2

    ON t1.company = t2.company

SET t1.industry = t2.industry

WHERE t1.industry IS NULL

AND t2.industry IS NOT NULL;

**-- If we check it looks like Bally's was the only one without a populated row to populate this null values**

SELECT *

FROM layoffs_stagings2

WHERE company LIKE 'Bally%';

![](/Layout_DC/DC11.png)

**-- 4. Remove any columns and Rows we need to remove**

SELECT *

FROM layoffs_stagings2

WHERE total_laid_off IS NULL

AND percentage_laid_off IS NULL;

**-- Deleting data that are not needed for the analysis**

DELETE 

FROM layoffs_stagings2

WHERE total_laid_off IS NULL

AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_stagings2

DROP COLUMN row_num;

SELECT *

FROM layoffs_stagings2;

![](/Layout_DC/DC1.png)

### Exploratory Data Analysis

SELECT *

FROM layoffs_stagings2;

![](/Layout_DC/DC1.png)

SELECT MAX(total_laid_off)

FROM layoffs_stagings2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)

FROM layoffs_stagings2;

![](/Layout_DC/DC12.png)

SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)

FROM layoffs_stagings2;

SELECT *

FROM layoffs_stagings2

WHERE percentage_laid_off = 1

ORDER BY total_laid_off DESC;

![](/Layout_DC/DC13.png)

SELECT *

FROM layoffs_stagings2

WHERE percentage_laid_off = 1

ORDER BY funds_raised_millions DESC;

![](/Layout_DC/DC14.png)

**-- Companies with the highest layoff**

SELECT company, SUM(total_laid_off)

FROM layoffs_stagings2

GROUP BY company

ORDER BY 2 DESC

LIMIT 7;

![](/Layout_DC/DC15.png)

**When is the start date and end date of the layoff?**

SELECT MIN(`date`), MAX(`date`)

FROM layoffs_stagings2;

![](/Layout_DC/DC16.png)

**-- What is the total laid off of the industries?**

SELECT industry, SUM(total_laid_off)

FROM layoffs_stagings2

GROUP BY industry

ORDER BY 2 DESC;

![](/Layout_DC/DC17.png)

**What is the Average percentage of tthe industry?**

SELECT industry, ROUND(AVG(percentage_laid_off),2) AS Average_percentage_laid_off

FROM layoffs_stagings2

WHERE percentage_laid_off IS NOT NULL

GROUP BY industry

ORDER BY Average_percentage_laid_off DESC;

![](/Layout_DC/DC18.png)

**-- What is the total laid off of each countries?**

SELECT country, SUM(total_laid_off)

FROM layoffs_stagings2

GROUP BY country

ORDER BY 2 DESC;

![](/Layout_DC/DC19.png)


**What is the average percentage laid off of the country?**

SELECT country, ROUND(AVG(percentage_laid_off),2) AS Average_percentage_laid_off

FROM layoffs_stagings2

WHERE percentage_laid_off IS NOT NULL

GROUP BY country

ORDER BY Average_percentage_laid_off DESC;

![](/Layout_DC/DC20.png)

SELECT company, industry, total_laid_off, percentage_laid_off

FROM layoffs_stagings2

ORDER BY total_laid_off DESC;

![](/Layout_DC/DC21.png)

**-- What is the total laid off for each year?**

SELECT YEAR(`date`), SUM(total_laid_off)

FROM layoffs_stagings2

GROUP BY YEAR(`date`)

ORDER BY 1 DESC;

![](/Layout_DC/DC222.png)

**-- What is the total laid off of each stage?**

SELECT stage, SUM(total_laid_off)
FROM layoffs_stagings2
GROUP BY stage
ORDER BY 2 DESC;

![](/Layout_DC/DC23.png)

SELECT stage, SUM(total_laid_off) AS total_laid_off

FROM layoffs_stagings2

WHERE stage IN ('Acquired', 'Post-IPO')

GROUP BY stage

ORDER BY 2 DESC;

![](/Layout_DC/DC24.png)

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)

FROM layoffs_stagings2

WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL

GROUP BY `MONTH`

ORDER BY 1 ASC;

![](/Layout_DC/DC25.png)

**-- Rolling total of Layoffs per Month**

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

![](/Layout_DC/DC26.png)

SELECT company, SUM(total_laid_off)

FROM layoffs_stagings2

GROUP BY company

ORDER BY 2 DESC;

![](/Layout_DC/DC27.png)

**-- Identify the top 5 companies with the highest percentage of layoffs.**

SELECT company, ROUND(SUM(percentage_laid_off),2)

FROM layoffs_stagings2

WHERE percentage_laid_off IS NOT NULL

GROUP BY company

ORDER BY 2 DESC

LIMIT 5;

![](/Layout_DC/DC28.png)

SELECT company, YEAR(`date`), SUM(total_laid_off)

FROM layoffs_stagings2

GROUP BY company, YEAR(`date`)

ORDER BY 3 DESC;

![](/Layout_DC/DC29.png)

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

![](/Layout_DC/DC36.png)

SELECT company, funds_raised_millions, SUM(total_laid_off)

FROM layoffs_stagings2

WHERE funds_raised_millions IS NOT NULL

GROUP BY company, funds_raised_millions

ORDER BY SUM(total_laid_off) DESC;

![](/Layout_DC/DC33.png)

**What is the Average funds raised in millions?

SELECT AVG(funds_raised_millions) AS Average_funds_raised

FROM layoffs_stagings2

WHERE total_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL;

![](/Layout_DC/DC35.png)

WITH significant_layoffs AS (
  
    SELECT *
    
    FROM layoffs_stagings2
    
    WHERE total_laid_off > 100  -- Filter companies with more than 100 layoffs

)

SELECT industry, SUM(total_laid_off) AS total_laid_off, ROUND(AVG(percentage_laid_off),2) AS Average_percentage_laid_off

FROM significant_layoffs

GROUP BY industry

ORDER BY total_laid_off DESC;

![](/Layout_DC/DC30.png)

**-- Relationship between the amounts of funds raised and percentage laid off**

SELECT funds_raised_millions, AVG(percentage_laid_off) AS avg_percentage_laid_off

FROM layoffs_stagings2

WHERE percentage_laid_off IS NOT NULL AND funds_raised_millions IS NOT NULL

GROUP BY funds_raised_millions

ORDER BY funds_raised_millions DESC;

![](/Layout_DC/DC31.png)

**-- Which sectors are most impacted by layoff?**
 
SELECT industry, COUNT(company) AS companies_affected, SUM(total_laid_off) AS total_laid_off

FROM layoffs_stagings2

WHERE total_laid_off IS NOT NULL

GROUP BY industry

ORDER BY total_laid_off DESC;

![](/Layout_DC/DC32.png)

Please refer to the [Layout Analysis Project](https://github.com/omoniyidamilola/Layoffs-SQL-Project/blob/main/Data%20Cleaning%20in%20SQL.sql).

## Possible Causes of Layoffs

### 1.	Economic Downturn

  **The global economic slowdown, triggered by factors like inflation, rising interest rates, and currency fluctuations, has forced companies to cut costs, leading to layoffs.**

### 2.	Overexpansion

  **Some tech companies may have overexpanded during periods of rapid growth, leading to an unsustainable workforce size when market conditions changed.**

### 3.	Industry Specific Challenges

  **Certain industries, like Aerospace and Travel, were hit particularly hard by the pandemic and subsequent economic challenges, necessitating significant layoffs.**

### 4.	Shifts in Consumer Behavior
 
  **Changes in consumer behavior, such as reduced spending and shifts to remote work, have impacted demand in certain sectors, leading to layoffs.**
 
### 5.	Technological Disruption

  **Advances in technology and automation have reduced the need for certain roles, particularly in industries like Retail and Consumer services, contributing to layoffs.**
 
### 6.	Post-IPO and Funding Pressures
	
  **Companies that recently went public or raised significant funding may face pressure to show profitability, leading to workforce reductions as a cost saving measure.**


## Recommendations for Stakeholders

### 1.	Strengthen Workforce Planning and Flexibility

-	**Recommendation**: Companies should regularly evaluate and adjust workforce sizes to match business needs, reducing the likelihood of large scale layoffs. Consider using contingent workers and temporary staff 
 during peak times to allow more flexibility.

- **Rationale**: Tech giants like Amazon and Google, despite their vast resources, faced significant layoffs. A more agile workforce strategy could have mitigated this impact.

### 2.	Focus on Financial and Strategic Resilience

-	**Recommendation**: Companies should develop robust financial and strategic contingency plans, particularly in uncertain economic climates, to ensure they can sustain operations without resorting to layoffs.

-	**Rationale**: The large number of layoffs in the Post-IPO stage highlights the importance of having strong financial buffers and strategic plans in place.

### 3.	Invest in Employee Reskilling and Redeployment

-	**Recommendation**: Companies should invest in reskilling programs to prepare employees for new roles within the organization, reducing the need for layoffs.

-	**Rationale**: Industries like Aerospace and Education, which saw high layoff percentages, would benefit from reskilling programs that allow for employee redeployment within the company.

### 4.	Enhanced Crisis Communication and Management

-	**Recommendation**: Develop comprehensive crisis communication strategies to manage layoffs transparently and compassionately, ensuring employees and stakeholders are well-informed.

-	**Rationale**: Effective communication during layoffs is crucial to maintaining trust and morale, as seen in the widespread impact across multiple industries.

### 5.	Explore Geographic and Industry Diversification

-	**Recommendation**: Companies should consider diversifying their operations across different regions and industries to spread risk and reduce the impact of economic downturns.

-	**Rationale**: The data shows that some countries, like the United States and India, experienced particularly high layoffs, suggesting a need for more diversified operations.

### 6.	Leverage Data for Predictive Insights

-	**Recommendation**: Utilize data analytics to anticipate economic downturns and make informed decisions about workforce adjustments before they become necessary.

-	**Rationale**: Predictive insights can help companies proactively manage their workforce and avoid the need for reactive layoffs.



