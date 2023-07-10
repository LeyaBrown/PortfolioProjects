SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--Select Data that we are going to be starting with 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United States'
ORDER BY 1,2;


--Looking at Total Cases vs Population
-- SHows what percentage of population infected with Covid
SELECT Location, date,population, total_cases,  (total_cases/population) * 100 
AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population
SELECT Location,population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group BY Location, population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with the Highest Death Count per Population
SELECT Location, MAX (total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Group BY Location
ORDER BY TotalDeathCount DESC;


-- BREAKING THINGS DOWN BY CONTINENT 

-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total population vs vaccination
-- Shows percentage of population that has recieved at least one Covid Vaccine
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perfrom Calculation on Partition By in previous query

WITH PopvsVac AS
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

--Using Temp Table to perfrom Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  continent nvarchar(225),
  location nvarchar(225),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths  AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

-- Creating View to store data for late visualizations
CREATE View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



