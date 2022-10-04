-- This will be exploratory analysis of the COVID-19 Dataset
-- Data is split between vaccinations and deaths, we will need to combine these two later on into one table

SELECT * FROM CovidDeaths$
ORDER BY 3,4

SELECT * FROM CovidVaccinations$
ORDER BY 3,4

-- immediately we see there are larger overall groupings such as "Africa" or "North America"
-- we want to remove these groups as to not mess with our grand totals we will calculate later on
SELECT * FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY 3,4

-- EXPLORATORY ANALYSIS 
-- will do some basic calculations and filter results for the United States

-- looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%states'
ORDER BY 1,2
-- Looking at Total Cases vs Population (shows what percentage of the population has gotten COVID)
SELECT location, date, population, total_cases, (total_cases / population)*100 AS PercentInfected
FROM CovidDeaths$
WHERE location like '%states'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection rate compared to Population
SELECT iso_code, location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY iso_code, location, population
ORDER BY PercentPopulationInfected DESC

--Breaking things down by continent/grouping THIS IS CORRECT WAY 
SELECT location, MAX(CAST (total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Now we want to combine the Deaths table with the Vaccination Table
-- selecting the columns we want from the deaths table
SELECT iso_code, continent, location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

-- selecting the columns we want from the vaccination table
SELECT iso_code, continent, location, date, total_vaccinations, new_vaccinations, people_vaccinated, people_fully_vaccinated
FROM CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Join the two tables on location/date
SELECT CovidDeaths$.iso_code, CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, total_cases, new_cases, total_deaths, CovidVaccinations$.total_vaccinations, CovidVaccinations$.new_vaccinations, CovidVaccinations$.people_vaccinated, CovidVaccinations$.people_fully_vaccinated
FROM CovidDeaths$
JOIN CovidVaccinations$ 
ON CovidDeaths$.location = CovidVaccinations$.location
AND CovidDeaths$.DATE = CovidVaccinations$.DATE
WHERE CovidDeaths$.continent IS NOT NULL
AND CovidVaccinations$.continent IS NOT NULL
ORDER BY 3,4
-- save the result to use for future visuals 
