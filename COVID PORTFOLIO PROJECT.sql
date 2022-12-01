USE PortfolioProject

SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
ORDER BY 3,4;

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

--Select the data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Nigeria%' AND continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
ORDER BY 1,2

--Total Cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE Location LIKE '%Nigeria%' AND continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared with Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

--Countries with the Highest Death per Population
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotaltDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY Location
ORDER BY TotaltDeathCount DESC

--LET'S BREAK THINGS DOWN NY CONTINENT
--Continent with the Highest Death Count
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotaltDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY continent
ORDER BY TotaltDeathCount DESC

--Continent with Highest Infection Rate compared with Population
SELECT continent, MAX(total_cases) AS HighestInfectionCount
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY continent
ORDER BY HighestInfectionCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)* 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


--Total Population vs New Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinationss as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3;

--Using CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinationss as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
 
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Create Temp  Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinationss as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Create Views for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinationss as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3;

CREATE VIEW TotalPopvsNewVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinationss as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3;

CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)* 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
--ORDER BY 1,2


CREATE VIEW ContinentHighInfRatevsPop AS
SELECT continent, MAX(total_cases) AS HighestInfectionCount
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY continent
--ORDER BY HighestInfectionCount DESC

CREATE VIEW ContinentHighDeathCount AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotaltDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY continent

CREATE VIEW CountryHighDeathPerPopulation AS
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotaltDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY Location

CREATE VIEW CountryHighInfRatevsPop AS
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL AND Location NOT LIKE '%Middle Income%'
GROUP BY Location, population

CREATE VIEW TotalCasesvsPopulation AS
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE Location LIKE '%Nigeria%' AND continent is NOT NULL AND Location NOT LIKE '%Middle Income%'

CREATE VIEW TotalCasesvsTotalDeaths AS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Nigeria%' AND continent is NOT NULL AND Location NOT LIKE '%Middle Income%'