select *
from Portfolioproject..coviddeaths
Where Continent is not null
order by 3,4

--select *
--from Portfolioproject..covidvaccination
--order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths, population
from Portfolioproject..coviddeaths
order by 1,2

--Looking at Total Cases VS Total Deaths
-- Shows Likelihood of Dying if you contract COVID in Bangladesh

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from Portfolioproject..coviddeaths
Where Location Like '%Bangladesh%'
order by 1,2

-- Looking at Total Cases VS Population
-- Shows What percentage of Population got COVID

select location,date,population,total_cases,(total_cases/population)*100 as Percent_Population_Infected
from Portfolioproject..coviddeaths
--Where Location Like '%Bangladesh%'
order by 1,2


--Looking at Countries with Highest Infection Rate Compared to Population

select location,population,MAX(total_cases) as HigestInfectionCount,MAX(total_cases/population)*100 as Percent_Population_Infected
from Portfolioproject..coviddeaths
--Where Location Like '%Bangladesh%'
Group by Location, population
order by Percent_Population_Infected

--Showing Countries with the Highest Death Count Per Population

select location,MAX(cast (total_deaths as int)) as Total_Death_Count
from Portfolioproject..coviddeaths
--Where Location Like '%Bangladesh%'
Where Continent is not null
Group by Location
order by Total_Death_Count desc

--Let's Break Things Down by CONTINENT

select location,MAX(cast (total_deaths as int)) as Total_Death_Count
from Portfolioproject..coviddeaths
--Where Location Like '%Bangladesh%'
Where Continent is not null
Group by location
order by Total_Death_Count desc


-- Showing The Continents With the Highest death count per Population

select continent,MAX(cast (total_deaths as int)) as Total_Death_Count
from Portfolioproject..coviddeaths
--Where Location Like '%Bangladesh%'
Where Continent is not null
Group by continent
order by Total_Death_Count desc


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases,SUM(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolioproject..coviddeaths
--Where Location Like '%Bangladesh%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations Numeric,
Rolling_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated