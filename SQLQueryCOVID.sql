Select *
From PortofolioProjectCovid..coviddeaths
where continent is not null
order by 3,4


Select *
From PortofolioProjectCovid..covidvaccination
order by 3,4

Select Location, date, total_cases,  new_cases, total_deaths, population
From PortofolioProjectCovid..coviddeaths
where continent is not null
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProjectCovid..coviddeaths
where location like '%indonesia%'
and continent is not null
order by 1,2


Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortofolioProjectCovid..coviddeaths
where location like '%indonesia%'
and continent is not null
order by 1,2

Select Location, population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortofolioProjectCovid..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by Location, population
order by PercentPopulationInfected desc

Select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortofolioProjectCovid..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by Location
order by TotalDeathsCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortofolioProjectCovid..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathsCount desc

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
From PortofolioProjectCovid..coviddeaths
--where location like '%indonesia%'
where continent is not null
group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
From PortofolioProjectCovid..coviddeaths
--where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2

Select *
FROM PortofolioProjectCovid..coviddeaths deaths
	Join PortofolioProjectCovid..covidvac vac
		On deaths.location = vac.location
		and deaths.date = vac.date

Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by deaths.location order by deaths.location) as RollingPeopleVaccinated
FROM PortofolioProjectCovid..coviddeaths deaths
	Join PortofolioProjectCovid..covidvac vac
		On deaths.location = vac.location
		and deaths.date = vac.date
where deaths.continent is not null
order by 1, 2, 3

-- CTE Population vs Vaccination 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by deaths.location order by deaths.location) as RollingPeopleVaccinated
FROM PortofolioProjectCovid..coviddeaths deaths
	Join PortofolioProjectCovid..covidvac vac
		On deaths.location = vac.location
		and deaths.date = vac.date
where deaths.continent is not null
--order by 1, 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by deaths.location order by deaths.location) as RollingPeopleVaccinated
FROM PortofolioProjectCovid..coviddeaths deaths
	Join PortofolioProjectCovid..covidvac vac
		On deaths.location = vac.location
		and deaths.date = vac.date
--where deaths.continent is not null
--order by 1, 2, 3
Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Create View

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by deaths.location order by deaths.location) as RollingPeopleVaccinated
FROM PortofolioProjectCovid..coviddeaths deaths
	Join PortofolioProjectCovid..covidvac vac
		On deaths.location = vac.location
		and deaths.date = vac.date
where deaths.continent is not null

Select *
From PercentPopulationVaccinated