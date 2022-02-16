-- By: Muhammad Haffizzan, Date: 12/02/2022, Data latest date: 10/02/2022
-- Making sure data import is success

SELECT *
FROM PortfolioProject..covid_death
ORDER BY 3,5 

SELECT *
FROM PortfolioProject..covid_vaccination
ORDER BY 3, 5

--Pointing out important data

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..covid_death
ORDER BY location, date

--Total case vs total death in the world 
--Total case vs total death in my country, Malaysia. 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM PortfolioProject..covid_death
ORDER BY location, date

CREATE VIEW DeathPercentCountry as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM PortfolioProject..covid_death
-- ORDER BY location, date

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM PortfolioProject..covid_death
WHERE location = 'Malaysia'
ORDER BY date

CREATE VIEW MalaysiaDeathPercent as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM PortfolioProject..covid_death
WHERE location = 'Malaysia'
--ORDER BY date

-- Total case vs population in the world. 
-- Total case vs population in Malaysia. 

SELECT location, date, total_cases, population, (total_cases/population)*100 as case_percent
FROM PortfolioProject..covid_death
ORDER BY location, date

CREATE VIEW WorldCases as
SELECT location, date, total_cases, population, (total_cases/population)*100 as case_percent
FROM PortfolioProject..covid_death
--ORDER BY location, date

SELECT location, date, total_cases, population, (total_cases/population)*100 as case_percent
FROM PortfolioProject..covid_death
WHERE location = 'Malaysia'
ORDER BY date

CREATE VIEW MalaysiaCasePercent as
SELECT location, date, total_cases, population, (total_cases/population)*100 as case_percent
FROM PortfolioProject..covid_death
WHERE location = 'Malaysia'
--ORDER BY date


--Total case vs population vs total death

SELECT location, date, total_cases, total_deaths, population,
	(total_cases/population)*100 as case_percent,
	(total_deaths/total_cases)*100 as death_percent
FROM PortfolioProject..covid_death
ORDER BY location, date

SELECT location, date, total_cases, total_deaths, population,
	(total_cases/population)*100 as case_percent, 
	(total_deaths/total_cases)*100 as death_percent
FROM PortfolioProject..covid_death
WHERE location = 'Malaysia'
ORDER BY date

CREATE VIEW MalaysiaSummary as
SELECT location, date, total_cases, total_deaths, population,
	(total_cases/population)*100 as case_percent, 
	(total_deaths/total_cases)*100 as death_percent
FROM PortfolioProject..covid_death
WHERE location = 'Malaysia'
--ORDER BY date

-- Retrieve the highest infection vs population

SELECT location, population, MAX(total_cases) as HighestCase,
	MAX((total_cases/population))*100 as case_percent
FROM PortfolioProject..covid_death
GROUP BY location, population
ORDER BY case_percent desc

-- Retrieve highest death count in each country
-- Some rows were removed since there are null values in continent column

SELECT location, MAX(CAST(total_deaths AS int)) as highest_death
FROM PortfolioProject..covid_death
WHERE continent is not null
GROUP BY location
ORDER BY highest_death desc

-- Retrieve total death in each continent

SELECT continent, MAX(CAST(total_deaths AS int)) as highest_death
FROM PortfolioProject..covid_death
GROUP BY continent
ORDER BY highest_death desc

-- Global numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..covid_death
WHERE continent is not null
GROUP BY date
ORDER BY date

CREATE VIEW GlobalNumbers as
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..covid_death
WHERE continent is not null
GROUP BY date
--ORDER BY date

-- Join table

SELECT *
FROM PortfolioProject..covid_death as cvdea
JOIN PortfolioProject..covid_vaccination as cvvac
	ON cvdea.location = cvvac.location
	and cvdea.date = cvvac.date
ORDER BY date

-- Total population vs Vaccination

SELECT cvdea.continent, cvdea.location, cvdea.date, cvdea.population, cvvac.new_vaccinations,
	SUM(convert(bigint, cvvac.new_vaccinations)) OVER (PARTITION BY cvdea.location ORDER BY cvdea.location, cvdea.date) as TotalVaccinated
FROM PortfolioProject..covid_death as cvdea
JOIN PortfolioProject..covid_vaccination as cvvac
	ON cvdea.location = cvvac.location
	and cvdea.date = cvvac.date
WHERE cvdea.continent is not null
ORDER BY 2, 3

-- USE CTE

WITH PopsvsVacc (continent, location, date, population, new_vaccination, TotalVaccinated)
as
(
SELECT cvdea.continent, cvdea.location, cvdea.date, cvdea.population, cvvac.new_vaccinations,
	SUM(convert(bigint, cvvac.new_vaccinations)) OVER (PARTITION BY cvdea.location ORDER BY cvdea.location, cvdea.date) as TotalVaccinated
FROM PortfolioProject..covid_death as cvdea
JOIN PortfolioProject..covid_vaccination as cvvac
	ON cvdea.location = cvvac.location
	and cvdea.date = cvvac.date
WHERE cvdea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (TotalVaccinated/population)*100 AS VaccinatedPercent
FROM PopsvsVacc

-- USE TEMP TABLE
-- Use drop table to avoid error of existed table due to code run multiple times

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
TotalVaccinated numeric,
)
insert into #PercentPopulationVaccinated
SELECT cvdea.continent, cvdea.location, cvdea.date, cvdea.population, cvvac.new_vaccinations,
	SUM(convert(bigint, cvvac.new_vaccinations)) OVER (PARTITION BY cvdea.location ORDER BY cvdea.location, cvdea.date) as TotalVaccinated
FROM PortfolioProject..covid_death as cvdea
JOIN PortfolioProject..covid_vaccination as cvvac
	ON cvdea.location = cvvac.location
	and cvdea.date = cvvac.date
-- WHERE cvdea.continent is not null
-- ORDER BY 2, 3

SELECT *, (TotalVaccinated/population)*100 AS VaccinatedPercent
FROM #PercentPopulationVaccinated


-- Creating View for data visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT cvdea.continent, cvdea.location, cvdea.date, cvdea.population, cvvac.new_vaccinations,
	SUM(convert(bigint, cvvac.new_vaccinations)) OVER (PARTITION BY cvdea.location ORDER BY cvdea.location, cvdea.date) as TotalVaccinated
FROM PortfolioProject..covid_death as cvdea
JOIN PortfolioProject..covid_vaccination as cvvac
	ON cvdea.location = cvvac.location
	and cvdea.date = cvvac.date
WHERE cvdea.continent is not null
-- ORDER BY 2, 3

CREATE VIEW MalaysiaVaccination as
WITH PopsvsVacc (continent, location, date, population, new_vaccination, TotalVaccinated)
as
(
SELECT cvdea.continent, cvdea.location, cvdea.date, cvdea.population, cvvac.new_vaccinations,
	SUM(convert(bigint, cvvac.new_vaccinations)) OVER (PARTITION BY cvdea.location ORDER BY cvdea.location, cvdea.date) as TotalVaccinated
FROM PortfolioProject..covid_death as cvdea
JOIN PortfolioProject..covid_vaccination as cvvac
	ON cvdea.location = cvvac.location
	and cvdea.date = cvvac.date
WHERE cvdea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (TotalVaccinated/population)*100 AS VaccinatedPercent
FROM PopsvsVacc
WHERE location = 'Malaysia'

-- List of Views: DeathPercentCountry, MalaysiaDeathPercent, WorldCases, MalaysiaCasePercent, MalaysiaSummary, GlobalNumbers, MalaysiaVaccination.
