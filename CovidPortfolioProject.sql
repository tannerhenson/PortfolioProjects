select *
from CovidDeaths
where continent is not null
order by 3,4

--select * 
--from CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--looking at total cases vs. total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs. population
select location, date, population, total_cases, (total_cases/population)*100 CasePercentage
from CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--counrties with highest infection rate
select location, population, max(total_cases) as HighestInfectionCoutn, max((total_cases/population))*100 PercPopInfected
from CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by PercPopInfected desc

--countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--broken down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

select continent, population, max(total_cases) as HighestInfectionCoutn, max((total_cases/population))*100 PercPopInfected
from CovidDeaths
--where location like '%states%'
where continent is not null
group by continent, population
order by PercPopInfected desc

--global numbers
 
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--^using nullif
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2


--looking at total population vs. vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)	
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated
