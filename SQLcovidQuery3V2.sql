Select *
From [PortfolioProject 1]..CovidDeaths
Where continent is not null
Order by 3,4
-- Select data we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject 1]..CovidDeaths
order by 1,2

-- Looking at the total cases vs the Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PortfolioProject 1]..CovidDeaths
Where location like '%states%'

order by 1,2

--Looking at Total Cases Vs. population
--Shows what percentage of population got covid

Select Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [PortfolioProject 1]..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at countries with highest Infection rate compared to Population

Select Location, population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [PortfolioProject 1]..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per Population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject 1]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENTS

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject 1]..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject 1]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date,SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM (cast(New_deaths as int))/SUM(New_cases)*100 as Deathpercentage
From [PortfolioProject 1]..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group By Date
order by 1,2
-- total cases and total deaths
Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM (cast(New_deaths as int))/SUM(New_cases)*100 as Deathpercentage
From [PortfolioProject 1]..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--Group By Date
order by 1,2

--Looking at Total Population vs Vaccinations

Select *
from [PortfolioProject 1]..CovidDeaths dea
Join [PortfolioProject 1]..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [PortfolioProject 1]..CovidDeaths dea
Join [PortfolioProject 1]..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [PortfolioProject 1]..CovidDeaths dea
Join [PortfolioProject 1]..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Partioning the Locations
--With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.population order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
--from [PortfolioProject 1]..CovidDeaths dea
--Join [PortfolioProject 1]..Vaccinations vac
--on dea.location = vac.location
--and dea.date = vac.date
--where dea.continent  is not null
--)
--order by 2,3

--new code cgpt

WITH PopvsVac AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.population ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    FROM [PortfolioProject 1]..CovidDeaths dea
    JOIN [PortfolioProject 1]..Vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

SELECT
    *,
    (RollingPeopleVaccinated / population) * 100 as VaccinationPercentage
FROM PopvsVac;


--USE CTE


Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Creat Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.population order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject 1]..CovidDeaths dea
Join [PortfolioProject 1]..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select *, (RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated


-- creating view to store data for later visualization

 
 create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.population order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject 1]..CovidDeaths dea
Join [PortfolioProject 1]..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3



--- created by sql
-- Drop code for SQL server.use this code if normal Drop code does not work. 
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;



CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.population ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
    (SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.population ORDER BY dea.location, dea.date) / dea.population) * 100 as VaccinationPercentage
FROM [PortfolioProject 1]..CovidDeaths dea
JOIN [PortfolioProject 1]..Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


Select * 
From PercentPopulationVaccinated
