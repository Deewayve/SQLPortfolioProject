Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

Select *
From PortfolioProject..CovidVaccinations
Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Likelihood of dying if you contacred Covid in Nigeria

Select location, date, total_cases, total_deaths, (Convert(float,total_deaths)/convert(float, total_cases)*100) as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
Order by 1,2

-- Percentage of population that got Covid

Select location, date, total_cases, population, (convert(float, total_cases)/ convert(float, population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
Order by 1,2

--Countries with Highest Infection Rate compared to Population

Select location, population, MAX(convert(float, total_cases)) as HighestInfectionCount, Max((convert(float, total_cases)/ convert(float, population)*100)) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Group By location, population
Order by PercentPopulationInfected Desc

--Countries with Highest Death count per population

Select location, MAX(convert(int, total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group By location
Order by TotalDeathCount Desc


--ORGANIZE BY CONTINENT
--Showing continents with thw highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where continent like '%Africa%'
Where continent is not null
Group By continent
Order by TotalDeathCount Desc


--Global Numbers
--Over time (From start of pandemic till now)
Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group By date
Order by 1,2

--Altogether
Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Order by 1,2


--Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingVaccinatedCount
--, (RollingVaccinatedCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3







--Using CTE
With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingVaccinatedCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingVaccinatedCount
--(RollingVaccinatedCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingVaccinatedCount/Population) * 100
From PopvsVac










--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedCount numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(numeric, new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingVaccinatedCount
--, (RollingVaccinatedCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingVaccinatedCount/Population) * 100
From #PercentPopulationVaccinated


-- Creating View to Store data for later viauslization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(numeric, new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingVaccinatedCount
--, (RollingVaccinatedCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3