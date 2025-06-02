use PortfolioProject;
select location,date,total_cases,new_cases,total_deaths,population from coviddeaths
order by 1,2; -- not a good practice to use order by using any numberic values i am doing it to finish it quickly otherwise i also use specific column name 
-- Updating null values where the rows are empty 
update coviddeaths
set total_deaths = NULL
where total_deaths = '';
-- Total deaths vs total cases and also the death percentage 
-- And also shows the liklihood of dying if suffereed from covid in ur country 
select location,date,total_cases,total_deaths, Round((total_deaths/total_cases)*100,2) as DeathPercentage from coviddeaths
where location like '%India%'
order by 1,2;
-- Total cases vs total population
-- And shows the total percentage of population who suffered from covid 
select location,date,total_cases,population, Round((total_cases/population)*100,2) as VictimPercentage from coviddeaths
where location like '%India%'
order by 1,2;
-- Countries with highest infection rate compared to population 
select location,Max(total_cases) as MaxInfection,population, Round(Max((total_cases/population))*100,2) as MaxInfectionRate from coviddeaths
group by location,population
order by MaxInfectionRate desc;
-- Countries with highest death counts per population
select location,Max(cast(total_deaths as SIGNED)) as MaxDeath from coviddeaths
where continent is not null
group by location
order by MaxDeath desc;
-- To check the data type 
desc coviddeaths;
-- Continent with highest death counts per population
select continent,Max(Cast(total_deaths as signed)) as MaxDeath from coviddeaths
where continent is not null
group by continent
order by MaxDeath desc;
select distinct continent from coviddeaths;
-- Global Number and percentage of death according to new cases and new deaths 
select sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths,
round((sum(cast(new_deaths as signed))/ sum(new_cases))*100,2) as global_death_percent
from coviddeaths
-- group by date 
order by 1,2;
-- Joining both the tables covid(deaths and vaccines)
select * from coviddeaths death
join covidvaccinations vaccine on 
death.location = vaccine.location and 
death.date = vaccine.date;


-- Looking at rate at which number of ppl vaccinated overtime 
with pop_vac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as (
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as signed)) over(partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from coviddeaths death
join covidvaccinations vaccine on 
death.location = vaccine.location and 
death.date = vaccine.date
where death.continent is not null
-- order by 2,3;
)
select *,(RollingPeopleVaccinated/population) * 100
from pop_vac;


-- calcualting same thing as what we did in the above query but this time by using Temp table 

Drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric ,
RollingPeopleVaccinated numeric 
); 

Insert into PercentPopulationVaccinated 
select death.continent,death.location,death.date,death.population,
nullif(vaccine.new_vaccinations,'') as new_vaccinations,
sum(cast(nullif(vaccine.new_vaccinations,'') as signed)) over(partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from coviddeaths death
join covidvaccinations vaccine on 
death.location = vaccine.location and 
death.date = vaccine.date;

select *, (RollingPeopleVaccinated/population) * 100
from PercentPopulationVaccinated;

-- Creating view to store data for later visualization 

create view view_of_percentage_of_ppl_vaccinated as 
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as signed)) over(partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from coviddeaths death
join covidvaccinations vaccine on 
death.location = vaccine.location and 
death.date = vaccine.date
where death.continent is not null;

select * from view_of_percentage_of_ppl_vaccinated;







































