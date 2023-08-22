--Select data what we are going to be using

Select location, date, total_cases,new_cases, total_deaths, population
From [COVID19Deaths&Vaccination]..['Covid Deaths']
Where continent is not null
Order by 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (CAST(total_deaths as float)/ Cast(total_cases as float))*100 as  DeathPercentage
From [COVID19Deaths&Vaccination]..['Covid Deaths']
Where location like '%kingdom%'
order by 1,2

--Looking at total cases vs population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases, population, (CAST(total_cases as float)/ Cast(population as float))*100 as  Affected_Percentage
From [COVID19Deaths&Vaccination]..['Covid Deaths']
Where location like '%kingdom%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as Highest_Infection_Count, (CAST(MAX(total_cases) as float)/ Cast(population as float))*100 as  Affected_Percentage
From [COVID19Deaths&Vaccination]..['Covid Deaths']
--Where location like '%kingdom%'
Group by location, population
order by Affected_Percentage desc

--Showing the Countries with death counts per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [COVID19Deaths&Vaccination]..['Covid Deaths']
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [COVID19Deaths&Vaccination]..['Covid Deaths']
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global numbers
Select date, Sum(Cast(new_cases as float)) as total_cases, Sum(Cast(new_deaths as float)) as total_deaths, (Sum(Cast(new_deaths as float)))/ (Sum(Cast(new_cases as float)))*100 as DeathPercentage
From [COVID19Deaths&Vaccination]..['Covid Deaths']
Where continent is not null
Group by date
Having Sum(Cast(new_deaths as int)) > 0 and Sum(Cast(new_cases as int)) > 0
ORDER BY 1,2

--Over the world
Select Sum(Cast(new_cases as float)) as total_cases, Sum(Cast(new_deaths as float)) as total_deaths, (Sum(Cast(new_deaths as float)))/ (Sum(Cast(new_cases as float)))*100 as DeathPercentage
From [COVID19Deaths&Vaccination]..['Covid Deaths']
Where continent is not null
--Group by date
Having Sum(Cast(new_deaths as int)) > 0 and Sum(Cast(new_cases as int)) > 0
ORDER BY 1,2

--Looking Total Population VS Vaccintation
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [COVID19Deaths&Vaccination]..['Covid Deaths'] dea
Join [COVID19Deaths&Vaccination]..['Covid Vaccintations'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [COVID19Deaths&Vaccination]..['Covid Deaths'] dea
Join [COVID19Deaths&Vaccination]..['Covid Vaccintations'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Nullif(Population,0))*100 as Vaccinatedpercentage
From PopvsVac

--Calculating population vs vaccination using temp table

Drop table if exists #PopulationvsVaccination
Create table #PopulationvsVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PopulationvsVaccination
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [COVID19Deaths&Vaccination]..['Covid Deaths'] dea
Join [COVID19Deaths&Vaccination]..['Covid Vaccintations'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Nullif(Population,0))*100 as Vaccinatedpercentage
From #PopulationvsVaccination

--Creating View to store data for later visualaizations

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [COVID19Deaths&Vaccination]..['Covid Deaths'] dea
Join [COVID19Deaths&Vaccination]..['Covid Vaccintations'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated1
