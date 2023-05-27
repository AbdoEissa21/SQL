select * 
from PortfolioProject..CovidDeaths
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

select location,date,total_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs total death

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths
where location like '%egy%'
order by 1,2

select location,date,total_cases,population,(total_cases/population)*100 as Cases_percentage
from PortfolioProject..CovidDeaths
where location like '%egy%'
order by 1,2

-- countries with the highest infaction rate

select location,max(total_cases) as HighestInfaction,population,Max((total_cases/population))*100 as Cases_percentage
from PortfolioProject..CovidDeaths
group by location,population
order by 4 desc


select location,max(cast(total_deaths as int)) as HighestDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeath desc

select continent,max(cast(total_deaths as int)) as HighestDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeath desc

--Global Death

select date,sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Death, sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage	
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Total population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



-- With CTE

with PopvsVac(Continent,Location,Date,Population,new_vaccinations,RollingPeopleVac)
as(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVac/Population)*100 
from PopvsVac


-- Temp table
drop table if exists #PercentPopulationVac
Create table #PercentPopulationVac
(
Continent nvarchar(255),Location nvarchar(255),Date datetime, Population numeric,New_vaccination numeric,RollingPeopleVac numeric
)
insert into #PercentPopulationVac
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVac/Population)*100 as Percentage
from #PercentPopulationVac

--Create View

create view PercentPopulationVac as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVac
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3