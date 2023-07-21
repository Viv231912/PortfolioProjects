Select *
From PortfolioProject..CovidDeaths
Where continent is null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood to death if you contract covid in your country

Select Location, date, total_cases, total_deaths, 
	(CAST(total_deaths as Int)) / (CAST(total_cases as Int))*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where continent is not null
	and location like '%australia%'
Order by 1, 2

-- Looking at Total Cases vs Populations
-- Shows what percentage of population got covid

Select Location, date, population, 
 total_cases, 	(CAST(total_cases AS INT))/(CAST(population AS INT))*100 as CovidPopulationPercentage
	From PortfolioProject..CovidDeaths
	Where continent is not null
	--Where location like '%australia%'
Order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population


Select Location, population, 
 MAX(total_cases)as HighestInfectionCount, 	
 MAX((CONVERT(float, total_cases)/CONVERT(float, population)))*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	Where continent is not null
	--Where location like '%australia%'
Group by location, population
Order by PercentPopulationInfected desc


-- Showing the Countries with Highest Death Count per Population 
Select Location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%australia%'
Group by location
Order by HighestDeathCount desc



--Let's break things down by Continent

Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
--Where location like '%australia%'
Group by continent 
Order by HighestDeathCount desc

-- BREAK DOWN BY CONTINENT

-- Showing Continents with Highest death count per population

Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
--Where location like '%australia%'
Group by continent 
Order by HighestDeathCount desc

-- GLOBAL NUMBERS

--Select date, SUM(new_cases), Sum(new_deaths), SUM(new_deaths)/Sum(new_cases)*100 as GobalRates
--From PortfolioProject..CovidDeaths
--Where continent is not null
----and location like '%australia%'
--Group by date 
--Order by 1, 2

--Select date, new_cases, new_deaths
--From PortfolioProject..CovidDeaths

Select  SUM(new_cases) AS Total_Cases, Sum(new_deaths) AS Total_Deaths,
CASE
	When SUM(new_deaths) = 0 Then Null
	Else Sum(new_deaths)/ NULLIF(Sum(new_cases), 0)*100 
END as GobalRates
From PortfolioProject..CovidDeaths
Where continent is not null
--and location like '%australia%'
--Group by date 
Order by 1, 2

--CovidVaccinations
-- Looking at Total Population Vs Vaccinations

Select Dea.continent, Dea.location, Dea.date, dea.population, Vac.new_vaccinations
, SUM(Convert(bigint, Vac.new_vaccinations)) 
Over (Partition by Dea.location Order by Dea.Location, Dea.Date) as TotalNewVac
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Vac.location = Dea.location 
	and Vac.date = Dea.date
Where Dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalNewVac)
as
(
Select Dea.continent, Dea.location, Dea.date, dea.population, Vac.new_vaccinations
, SUM(Convert(bigint, Vac.new_vaccinations)) 
Over (Partition by Dea.location Order by Dea.Location, Dea.Date) as TotalNewVac
--, (Total)
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Vac.location = Dea.location 
	and Vac.date = Dea.date
Where Dea.continent is not null
--Order by 2, 3
)

Select *, (TotalNewVac/Population) *100
From PopvsVac

--TEMP TABLE
Drop table if Exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(continent nvarchar(255), 
location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
TotalNewVac numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, dea.population, Vac.new_vaccinations
, SUM(Convert(bigint, Vac.new_vaccinations)) 
Over (Partition by Dea.location Order by Dea.Location, Dea.Date) as TotalNewVac
--, (Total)
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Vac.location = Dea.location 
	and Vac.date = Dea.date
--Where Dea.continent is not null
--Order by 2, 3

Select *, (TotalNewVac/Population) *100
From #PercentPopulationVaccinated


-- Creating View to store data for later visulaisation

Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, dea.population, Vac.new_vaccinations
, SUM(Convert(bigint, Vac.new_vaccinations)) 
Over (Partition by Dea.location Order by Dea.Location, Dea.Date) as TotalNewVac
--, (Total)
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Vac.location = Dea.location 
	and Vac.date = Dea.date
Where Dea.continent is not null
--Order by 2, 3


Select *
From PercentPopulationVaccinated


--Select *
--From PortfolioProject..CovidVaccinations
--Where location = 'Canada' and date = '2021-04-21'
