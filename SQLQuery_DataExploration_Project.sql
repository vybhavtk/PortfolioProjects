/*
Covid 19 Data Exploration 
*/


SELECT * FROM
CovidDeaths
ORDER BY 3,4

SELECT * FROM
CovidVaccinations
ORDER BY 3,4



-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, population
FROM CovidDeaths
ORDER BY 1,2



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
where location = 'India'
ORDER BY 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
FROM CovidDeaths
where location = 'India'
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases)/population)*100 AS InfectionRate
FROM CovidDeaths
group by location, population
order by InfectionRate DESC



-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM CovidDeaths
where continent is not null
group by location
order by TotalDeaths DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS CasesNumber, SUM(CAST (new_deaths AS INT)) AS DeathsNumber, SUM(CAST (new_deaths AS INT))*100/SUM(new_cases) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT *
FROM CovidDeaths dt
JOIN CovidVaccinations vc
ON dt.location = vc.location AND dt.date = vc.date

SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations
FROM CovidDeaths dt JOIN CovidVaccinations vc
ON dt.date = vc.date AND dt.location = vc.location
WHERE dt.continent IS NOT NULL
ORDER BY 2,3


SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, 
SUM(CAST(vc.new_vaccinations AS BIGINT)) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS RollingVaccination
FROM CovidDeaths dt JOIN CovidVaccinations vc
ON dt.date = vc.date AND dt.location = vc.location
WHERE dt.continent IS NOT NULL
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query

WITH popNvac AS
(SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations, 
SUM(CAST(vc.new_vaccinations AS BIGINT)) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS RollingVaccination
FROM CovidDeaths dt JOIN CovidVaccinations vc
ON dt.date = vc.date AND dt.location = vc.location
WHERE dt.continent IS NOT NULL
)
SELECT *, (RollingVaccination/population)*100
FROM popNvac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated