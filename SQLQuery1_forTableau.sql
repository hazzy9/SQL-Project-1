--covid cases, death cases, & 치사율 (계산)

Select * from Porfolio_Practice..CovidDeaths$
Order by 3,4

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From ..CovidDeaths$
Where location like '%orea%'
Order by 1,2

--Total cases VS. Population (population % with covid)
Select location, date, Population,total_cases,  (total_cases/population)*100 as InfectionRate
From Porfolio_Practice..CovidDeaths$
Where location like 'South Korea'
Order by 1,2

--Highest Infection % between countries


Select Location,Population,Max(total_cases)as HighestInfection,  max((total_cases/population))*100 as Highest_Infection_Percentage
From Porfolio_Practice..CovidDeaths$
Group by Location, Population
Order by Highest_Infection_Percentage desc

--Highest Death % (+ infection %)
Select Location, Max(cast(total_deaths as int)) as Deaths, max((cast(total_deaths as int)/total_cases)*100) as Death_Rate,
max((total_cases/population))*100 as Infection_Percentage
From Porfolio_Practice..CovidDeaths$
Where continent is not null
Group by Location
Order by Death_Rate desc

--by continent
Select Continent,  Max(cast(total_deaths as int)) as Deaths
From Porfolio_Practice..CovidDeaths$
Where continent is not null
Group by Continent
Order by Deaths desc

-- Showing countinents with the highest death count per population
Select Continent,  Max(cast(total_deaths as int)/population)*100 as DeathsPerPopulation
From Porfolio_Practice..CovidDeaths$
Where continent is not null
Group by Continent
Order by DeathsPerPopulation desc

--Global numbers (aggregate functions)
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPerc
From Porfolio_Practice..CovidDeaths$
where continent is not null
--Group by date
order by 1,2


--Join with Covid Vaccination dataset
Select *
From Porfolio_Practice..CovidDeaths$ dea
Join Porfolio_Practice..CovidVaccinations$ vac
	On  dea.location = vac.location
	and dea.date = vac.date

--Total population VS. Vaccinations (use CTE)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From Porfolio_Practice..CovidDeaths$ dea
Join Porfolio_Practice..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date  = vac.date
Where dea.continent is not null)
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
Order by 2,3

--Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Porfolio_Practice..CovidDeaths$ dea
Join Porfolio_Practice..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/	Population)*100
from #PercentPopulationVaccinated




--Create a view to store data for later visualizations
Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
,dea.Date) as RollingPeopleVaccinated
From Porfolio_Practice..CovidDeaths$ dea
Join Porfolio_Practice..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From Porfolio_Practice..CovidDeaths$ dea
Join Porfolio_Practice..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date  = vac.date
Where dea.continent is not null

