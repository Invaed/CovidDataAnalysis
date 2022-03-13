select * 
from [dbo].[CovidDeaths] 
order by 3,4

--select * 
--from [dbo].[CovidVaccinations]
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject1..CovidDeaths 
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelyhood of death upon contracting covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths 
Where location like '%States%'
order by 1,2

-- Looking at the total cases vs Population
-- Shows what % of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as CovidPositivePercentage
From PortfolioProject1..CovidDeaths 
Where location like '%States%'
order by 1,2

-- Looking at countries with Highest Infection rate 
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_deaths/total_cases))*100 as PercentagePopulationInfected
From PortfolioProject1..CovidDeaths 
-- Where location like '%States%'
group by location, population
order by PercentagePopulationInfected desc

-- Showing countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths 
-- Where location like '%States%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Grouping by continent
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths 
-- Where location like '%States%'
where continent is null
group by location
order by TotalDeathCount desc

select * 
from PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4

-- showing continent with hightest death count
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths 
-- Where location like '%States%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers
Select SUM(new_cases) as TotalCases, 
SUM(cast (new_deaths as int)) as TotalDeaths, 
SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths 
-- Where location like '%States%'
where continent is not null 
--group by date
order by 1,2


-- looking at total population vs vaccination
with PopvsVac( Continent, Location, Date, Population, new_vaccinations ,RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
 on dea.location=vac.location 
 and dea.date=vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

-- TempTable
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(decimal, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
     on dea.location=vac.location 
     and dea.date=vac.date
--where dea.continent is not null
--order by 2, 3

Select *,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- Cereating view
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(decimal, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
     on dea.location=vac.location 
     and dea.date=vac.date
where dea.continent is not null
--order by 2, 3