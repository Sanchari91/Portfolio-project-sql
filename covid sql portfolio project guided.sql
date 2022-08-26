Select *
From portfolioproject..coviddeath$
Where continent is not null
order by 3,4

Select *
From portfolioproject..coviddeath$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..coviddeath$
order by 1,2

--looking at total cases vs total deaths

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From portfolioproject..coviddeath$
where location = 'India'
order by 1,2

--total cases vs total population
Select location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as deathperhundredpop
From portfolioproject..coviddeath$
where location = 'India'
order by 1,2

--countries with highest infection rates
Select location, population, MAX(total_cases) as maxinfection, MAX((total_cases/population))*100 as percentage_infected
From portfolioproject..coviddeath$
Group by location, population
order by maxinfection desc

 
 --countries with highest death rates
Select location, MAX(cast(total_deaths as int)) as totaldeathcount
From portfolioproject..coviddeath$
Where continent is not null
Group by location
order by totaldeathcount desc

--continent wise death rates
Select continent, MAX(cast(total_deaths as int)) as totalDeaths
From portfolioproject..coviddeath$
Where continent is not null
Group by continent
Order by totalDeaths desc


--Global Scenario

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From portfolioproject..coviddeath$
where continent is not null
order by 1,2

select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject..coviddeath$
where continent is not null
Group by date
order by 1,2


--total population vs vaccination 

select *
from portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as rollingvacs
from portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with popvsvac(Continent, location, date, population, new_vaccinations, rollingvacs)
as
(
Select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as rollingvacs
from portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(rollingvacs/population)*100
From popvsvac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
rollingvacs numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as rollingvacs
from portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccinated$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*,(rollingvacs/population)*100
From #PercentPopulationVaccinated
