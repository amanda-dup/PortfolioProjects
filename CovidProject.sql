Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4

Select *
From PortfolioProject..CovidVaccinations
order by 3, 4

 -- Data we are going to use

 Select Location, date, total_cases, new_cases, total_deaths, population 
 From PortfolioProject..CovidDeaths
 Where continent is not null
 order by 1,2

 -- Looking at Total Cases vs. Total Deaths
 -- Shows the likelihood of dying from contracting covid by country

 Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 where location = 'United States' and continent is not null
 order by 1,2

 -- Looking at Total Cases vs. Population
 -- Shows what % of population got Covid

 Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
 From PortfolioProject..CovidDeaths
 where location = 'United States' and continent is not null
 order by 1,2

 -- Looking at Countries with Highest Infection Rate compared to Population

  Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by Location, Population
 order by InfectionRate desc

 -- Countries with Highest Death Count per Population

 Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by Location
 order by TotalDeathCount desc

 -- Global numbers

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 Where continent is not null
 order by 1,2

 Select *
 From PortfolioProject..CovidDeaths deaths
 Join PortfolioProject..CovidVaccinations vacc
	On deaths.location = vacc.location and deaths.date = vacc.date

-- Total Population vs Vaccinations 

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	On deaths.location = vacc.location 
	and deaths.date = vacc.date
where deaths.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	On deaths.location = vacc.location 
	and deaths.date = vacc.date
where deaths.continent is not null
)
Select *, (RollingVaccinations/Population)*100
From PopvsVac


-- Temp table


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	On deaths.location = vacc.location 
	and deaths.date = vacc.date


Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated

-- Creating view to store date for later visualizations

Create View PercentPopulationVaccinated as 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
	SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingVaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	On deaths.location = vacc.location 
	and deaths.date = vacc.date
where deaths.continent is not null