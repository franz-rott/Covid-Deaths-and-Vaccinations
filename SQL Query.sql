-- Inspect Tables 
SELECT 
	* 
FROM 
	SQL_project.dbo.CovidDeaths
ORDER BY 
	3, 4;

SELECT 
	* 
FROM 
	SQL_project.dbo.CovidVaccinations
ORDER BY 
	3, 4;


-- Total Covid Deaths / Total Covid Cases per Country
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CAST(total_deaths AS decimal(20,4)) / CAST(total_cases AS decimal(20,4)) * 100 AS death_percentage
FROM
    SQL_project.dbo.CovidDeaths
WHERE continent is not Null
ORDER BY
    1, 2;

-- Inspect Germany
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CAST(total_deaths AS decimal(20,4)) / CAST(total_cases AS decimal(20,4)) * 100 AS death_percentage
FROM
    SQL_project.dbo.CovidDeaths
WHERE
	location like '%German%' 
ORDER BY
    1, 2;


-- we can see, that the death-percentage is greater than 100 in the early days of covid
-- we have to fix this data error 
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN CAST(total_deaths AS decimal(20,4)) / NULLIF(CAST(total_cases AS decimal(20,4)), 0) * 100 > 100
        THEN NULL
        ELSE CAST(total_deaths AS decimal(20,4)) / NULLIF(CAST(total_cases AS decimal(20,4)), 0) * 100
    END AS death_percentage
FROM
    SQL_project.dbo.CovidDeaths
WHERE
    location LIKE '%German%'
ORDER BY
    1, 2;


-- Total Covid Deaths / Population for Germany
SELECT
    location,
	population,
    total_deaths,
	CAST(total_deaths AS decimal(20,4)) / (CAST(population AS decimal(20,4))) * 100 AS death_percentage
FROM
    SQL_project.dbo.CovidDeaths
WHERE
    location LIKE '%German%'
ORDER BY
    1, 2;



-- Sorting Countries regarding their highest total cases per population
SELECT
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    (CAST(MAX(total_cases) AS decimal(20,4)) / CAST(population AS decimal(20,4)) * 100) AS max_total_cases_percentage
FROM
    SQL_project.dbo.CovidDeaths
WHERE 
	continent is not Null
GROUP BY 
    location, population
ORDER BY
    max_total_cases_percentage DESC;


-- Sorting Countries regarding their highest death cases per population
SELECT
    location,
    population,
    MAX(total_deaths) AS highest_death_count,
    (CAST(MAX(total_deaths) AS decimal(20,4)) / CAST(population AS decimal(20,4)) * 100) AS max_total_deaths_percentage
FROM
    SQL_project.dbo.CovidDeaths
WHERE
	continent is not Null
GROUP BY 
    location, population
ORDER BY
    max_total_deaths_percentage DESC;


-- Sorting Continents regarding their highest death cases per population
SELECT
    location,
    population,
    MAX(total_deaths) AS highest_death_count,
    (CAST(MAX(total_deaths) AS decimal(20,4)) / CAST(population AS decimal(20,4)) * 100) AS max_total_deaths_percentage
FROM
    SQL_project.dbo.CovidDeaths
WHERE
	continent is Null
GROUP BY 
    location, population
ORDER BY
    max_total_deaths_percentage DESC;



-- Sorting Continents regarding their highest death count
SELECT
    continent,
    MAX(total_deaths) AS max_total_deaths
FROM
    SQL_project.dbo.CovidDeaths
WHERE
	continent is not Null
GROUP BY 
    continent
ORDER BY
    max_total_deaths DESC;


-- Global Numbers per Day
SELECT
    date,
    SUM(new_cases) AS global_new_cases,
    SUM(new_deaths) AS global_new_deaths,
    ((CAST(SUM(new_deaths) AS decimal(20,4))) / NULLIF(SUM(new_cases), 0)) -- Use NULLIF to handle division by zero
FROM
    SQL_project.dbo.CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    date;

-- Global Numbers in Total
SELECT
    SUM(new_cases) AS global_new_cases,
    SUM(new_deaths) AS global_new_deaths,
    ((CAST(SUM(new_deaths) AS decimal(20,4))) / NULLIF(SUM(new_cases), 0)) AS global_death_rate-- Use NULLIF to handle division by zero
FROM
    SQL_project.dbo.CovidDeaths
WHERE
    continent IS NOT NULL



--Looking at Total Population vs Vaccinations
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations
FROM 
	SQL_project.dbo.CovidDeaths dea
Join 
	SQL_project.dbo.CovidVaccinations vac
	On 
		dea.location = vac.location 
		and dea.date = vac.date
WHERE
	dea.continent is not Null
ORDER BY
	2, 3


--Total Vaccination vs Population in Percent
WITH PopVsVacc (Continent, Location, Date, Population, NewVaccinations, RollingVaccination)
AS (	
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS decimal(20,4))) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS rolling_vaccinations
FROM 
	SQL_project.dbo.CovidDeaths dea
Join 
	SQL_project.dbo.CovidVaccinations vac
	On 
		dea.location = vac.location 
		and dea.date = vac.date
WHERE
	dea.continent is not Null
)
Select 
	*, 
	(RollingVaccination / Population)*100 AS VaccinationPercentage
FROM PopVsVacc
