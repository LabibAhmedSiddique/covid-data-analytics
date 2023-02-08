select *
from SQL_Project..CovidDeaths$

order by 3,4

--select *
--from SQL_Project..CovidVaccinations$
--order by 3,4

select location , date,total_cases, new_cases, total_deaths,population
from SQL_Project..CovidDeaths$
order by 1,2


select location , date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathParcentage
from SQL_Project..CovidDeaths$
where location like '%states%'
order by 1,2

--exploring total cases vs population
-- shows infection rate
select location , date,total_cases, population,(total_cases/population)*100 as InfectionRate
from SQL_Project..CovidDeaths$
--where location like '%states%'
order by 1,2

--showing counties with highest infount per population
select location , population,MAX(total_cases) as HighestinfrctionCount, MAX((total_cases/population))*100 as ParcentPopulationInfected
from SQL_Project..CovidDeaths$
Group by location , population
order by ParcentPopulationInfected desc

-- death count by population 
select location , population,MAX(cast(total_deaths as int)) as TotalDeathCount
from SQL_Project..CovidDeaths$
Group by location , population
order by TotalDeathCount desc

-- showing the continents with highest deathcount
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from SQL_Project..CovidDeaths$

Where continent is not null 
Group by continent
order by TotalDeathCount desc

--global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from SQL_Project..CovidDeaths$ 
where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
with PopvsVac ( Continent, location ,date , population ,new_vaccinations ,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL_Project..CovidDeaths$ dea
Join SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
select *, (RollingPeopleVaccinated /population) *100
from PopvsVac
--USE CTE



--Temp table
create table #parcentPopulationVaccinated(
Continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #parcentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL_Project..CovidDeaths$ dea
Join SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *, (RollingPeopleVaccinated /population) *100
from #parcentPopulationVaccinated

--visualization
create view ParcentVAccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL_Project..CovidDeaths$ dea
Join SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from ParcentVAccinated