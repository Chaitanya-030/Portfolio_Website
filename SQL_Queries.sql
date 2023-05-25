select * from Portfolio_Project.dbo.CovidDeaths$
order by 1,2

-- select * from Portfolio_Project.dbo.CovidVaccinations$
-- order by 1,2

select location, total_cases, new_cases, total_deaths, population
from Portfolio_Project.dbo.CovidDeaths$
order by 1,2

-- alter table Portfolio_Project.dbo.CovidDeaths$
-- alter column total_deaths real

-- alter table Portfolio_Project.dbo.CovidDeaths$
-- alter column total_cases real

-- Total Cases VS Total Deaths
select location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project.dbo.CovidDeaths$
order by 1,2

-- Shows likelihood of dying in my country
select location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project.dbo.CovidDeaths$ 
where location like 'india'
order by 1,2

-- Total Cases VS Population (percentage of population affected by covid)
select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
from Portfolio_Project.dbo.CovidDeaths$ 
where location like 'india'
order by 1,2

-- Countries with highest infection rate wrt population
select location, population, max(total_cases) as MaxInfectionCount, max((total_cases/population)*100) as CasesPercentage
from Portfolio_Project.dbo.CovidDeaths$ 
group by location, population
order by CasesPercentage desc

-- Countries with highest death count per population
select location, population, sum(total_deaths) as TotalDeathCount, max((total_deaths/population)*100) as DeathPercentage
from Portfolio_Project.dbo.CovidDeaths$ 
where continent is not null
group by location, population
order by DeathPercentage desc

-- CONTINENT-WISE
select location, max(total_deaths) as TotalDeathCount
from Portfolio_Project.dbo.CovidDeaths$ 
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths
from Portfolio_Project.dbo.CovidDeaths$
where continent is not null
-- group by date
order by 1,2 


select * from Portfolio_Project.dbo.CovidVaccinations$
order by 1,2

-- Total population vs Vaccination
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as  RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 --> We cannot use alias as a variable column name
from Portfolio_Project.dbo.CovidDeaths$ death
join Portfolio_Project.dbo.CovidVaccinations$ vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
order by 1, 2


-- USING CTE:
With popVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as  RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 --> We cannot use alias as a variable column name
from Portfolio_Project.dbo.CovidDeaths$ death
join Portfolio_Project.dbo.CovidVaccinations$ vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
-- order by 1, 2
)

select *, (RollingPeopleVaccinated/population)*100
from popVSvac

-- USING TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as  RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 --> We cannot use alias as a variable column name
from Portfolio_Project.dbo.CovidDeaths$ death
join Portfolio_Project.dbo.CovidVaccinations$ vac
on death.location = vac.location and death.date = vac.date
-- where death.continent is not null
-- order by 1, 2

select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated


-- creating view to store data for later visualizations
create view percentpopulationvaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as  RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 --> We cannot use alias as a variable column name
from Portfolio_Project.dbo.CovidDeaths$ death
join Portfolio_Project.dbo.CovidVaccinations$ vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
-- order by 1, 2

select * from percentpopulationvaccinated