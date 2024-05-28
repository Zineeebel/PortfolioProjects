-- Select Data that we are going to be using
 
 SELECT location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

 -- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths,  CAST((total_deaths * 100.0 / total_cases) AS FLOAT) as DeathPercentage 
From CovidDeaths
WHERE continent is NOT NULL
 ORDER BY 1,2


 -- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths * 100.0 / total_cases) as DeathPercentage 
From CovidDeaths
WHERE continent is NOT NULL
WHERE location LIKE '%states%'
 ORDER BY 1,2

-- Looking at Total Cases vs Population
 -- Shows what percentage of population got covid

SELECT location, date, population,total_cases, (total_cases * 100.0 / population) as CovidPercentage 
From CovidDeaths
WHERE [location] LIKE '%states%'
WHERE continent is NOT NULL
ORDER BY 1,2

SELECT location, date, population,total_cases, (total_cases * 100.0 / population) as CovidPercentage 
From CovidDeaths
WHERE continent is NOT NULL
--WHERE [location] LIKE '%states%'
 ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases * 100.0 / population) as PercentagePopulationInfected
From CovidDeaths WHERE continent is NOT NULL
GROUP by [location], population
ORDER BY 1,2

 -- Looking at countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases * 100.0 / population) as PercentagePopulationInfected
From CovidDeaths
WHERE continent is NOT NULL
GROUP by [location], population
ORDER BY PercentagePopulationInfected DESC

 -- Showing countries with highest death count per population

SELECT location,MAX(total_deaths) as TotalDeathCount
From CovidDeaths
WHERE continent is NOT NULL
GROUP by location
ORDER BY TotalDeathCount DESC

-- Let' break things down by continent

SELECT continent,MAX(total_deaths) as TotalDeathCount
From CovidDeaths
WHERE continent is NOT NULL
GROUP by continent
ORDER BY TotalDeathCount DESC

SELECT location,MAX(total_deaths) as TotalDeathCount
From CovidDeaths
WHERE continent is NULL
GROUP by [location]
ORDER BY TotalDeathCount DESC

-- Showing continents with highest death count per population

SELECT continent,MAX(total_deaths) as TotalDeathCount
From CovidDeaths
WHERE continent is NOT NULL
GROUP by continent
ORDER BY TotalDeathCount DESC
-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) * 100.0 / SUM(new_cases)) as DeathPercentage 
From CovidDeaths
WHERE continent is not NULL
GROUP by [date]
ORDER BY 1,2
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) * 100.0 / SUM(new_cases)) as DeathPercentage 
From CovidDeaths
WHERE continent is not NULL
 ORDER BY 1,2

--Looking at total population vs vaccination

SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
WHERE dea.continent is NOT NULL
-- ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated * 100.0 /population)
FROM PopvsVac

-- Temp table
DROP TABLE if EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR (255),
    LOCATION NVARCHAR (255),
    DATE DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
-- WHERE dea.continent is NOT NULL
-- ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated * 100.0 /population)
FROM #PercentPopulationVaccinated


-- Creating View to store data later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
WHERE dea.continent is NOT NULL
--ORDER BY 2,3