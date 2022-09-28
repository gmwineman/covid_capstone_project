SELECT * FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using -- 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%states'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of the population has gotten COVID
SELECT location, date, population, total_cases, (total_cases / population)*100 AS PercentInfected
FROM CovidDeaths$
-- WHERE location like '%states'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest DeathCount per Population
SELECT location, MAX(CAST (total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by continent THIS IS CORRECT WAY 
SELECT location, MAX(CAST (total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--THIS IS INCORRECT WAY TO BREAK DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

 --GLOBAL NUMBERS EACH DAY
SELECT DATE, SUM(NEW_CASES) AS TotalCases, SUM(CAST(NEW_DEATHS AS INT)) AS TotalDeaths, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- TOTAL GLOBAL NUMBERS
SELECT SUM(NEW_CASES) AS TOTAL_CASES, SUM(CAST(NEW_DEATHS AS INT)) AS TOTAL_DEATHS, 
SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT * FROM CovidVaccinations$

--JOINING THE TWO TABLES
SELECT * 
FROM CovidDeaths$
JOIN CovidVaccinations$ 
ON CovidDeaths$.location = CovidVaccinations$.location
AND CovidDeaths$.DATE = CovidVaccinations$.DATE

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated 
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.location like 'albania'
ORDER BY 2,3


--CREATE ROLLING TOTAL
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.location like 'albania'
ORDER BY 2,3

-- USE CTE
With PopvsVac (Contintent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PctTotalPopVaccinated
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccianted(
	Contintent nvarchar(255),
	Location nvarchar(255),
	Date  datetime,
	Population numeric,
	NewVaccinations numeric, 
	RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccianted 

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent is not null

SELECT * FROM #PercentPopulationVaccianted

-- Creating View to Sort Data for Later Viz
CREATE VIEW PercentPopulationVaccinated AS 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(BIGINT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths$ DEA
JOIN CovidVaccinations$ VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.continent is not null
