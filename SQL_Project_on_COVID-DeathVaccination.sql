
--Lets Check Whole CovidDeaths Table with Order By Clause
----------------------------------------------------------
SELECT *
FROM PortfolioProject_1..CovidDeaths
ORDER BY 3,4



--Lets Check Whole CovidVaccinations Table witnh Order BY Clause
-----------------------------------------------------------------
SELECT *
FROM PortfolioProject_1..CovidVaccinations
ORDER BY 3,4



--Using CovidDeaths table and selecting some data
--------------------------------------------------
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_1..CovidDeaths
ORDER BY 1,2



--Looking at Total Cases Vs Total Deaths and using Where Clause here
---------------------------------------------------------------------
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE location = 'India' and continent is not null
ORDER BY 1,2



--Looking at Total Cases Vs Populations
----------------------------------------
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentInfectedCase
FROM PortfolioProject_1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2



--Looking at countries with Highest Infection Rate compared to Population with using some Functions and also Group By Clause
-----------------------------------------------------------------------------------------------------------------------------
SELECT location, population, MAX(total_cases) as HighestCaseCount, MAX((total_cases/population))*100 as PercentInfectedCase
FROM PortfolioProject_1..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY HighestCaseCount desc



--Looking at countries with Highest Death Count per Population
---------------------------------------------------------------
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc



--Looking at continents with Highest Death Count per Population
----------------------------------------------------------------
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--With Global Numbers
----------------------
SELECT sum(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE continent is not null --and new_cases is not null
ORDER BY 1,2



-- USING JOINS (looking at total_population vs vaccination)
------------------------------------------------------------
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.date) as RollingPeopleVaccinate
FROM PortfolioProject_1..CovidDeaths dea
JOIN PortfolioProject_1..CovidVaccinations vac
	On dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
ORDER BY 2,3



-- USING CTE
-------------
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinate)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.date) as RollingPeopleVaccinate
FROM PortfolioProject_1..CovidDeaths dea
JOIN PortfolioProject_1..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
)
SELECT *,(RollingPeopleVaccinate/population)*100 as VaccinatedPerPopulation
FROM popvsvac



--USING TEMP TABLE
-------------------
DROP TABLE if exists #VaccinatedPerPopulation
CREATE TABLE #VaccinatedPerPopulation
	(continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinate numeric)

INSERT INTO #VaccinatedPerPopulation
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.date) as RollingPeopleVaccinate
FROM PortfolioProject_1..CovidDeaths dea
JOIN PortfolioProject_1..CovidVaccinations vac
	On dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null

SELECT *,(RollingPeopleVaccinate/population)*100 as VaccinatedPerPopulation
FROM #VaccinatedPerPopulation



--CREATING VIEW to store for later visualizations
--------------------------------------------------
CREATE VIEW VaccinatedPerPopulation AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.date) as RollingPeopleVaccinate
FROM PortfolioProject_1..CovidDeaths dea
JOIN PortfolioProject_1..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null

--CHECKING VIEW
----------------
SELECT *
FROM VaccinatedPerPopulation