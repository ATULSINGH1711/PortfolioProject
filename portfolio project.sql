select location, date , total_cases,new_cases,total_deaths, population
from [portfolio_project].[dbo].[covid_death];

--looking at the totoal cases vs total deaths.

--showing death percentage as per the country.

select location, date , total_cases,total_deaths,
	round((total_deaths/total_cases) * 100,2) as Death_Percentage
		from [portfolio_project].[dbo].[covid_death]
			order by location, date ;

-- looking at the total cases vs population. 

select location, date , total_cases,population,
	round((total_cases/population) * 100,2) as Percentage_population_Infected
		from [portfolio_project].[dbo].[covid_death]
			order by location,date;


-- looking at the country with the Highest_infection_Percentage compared to the population.

select location ,population, max(total_cases) as Highest_infection_count,
	max((total_cases / population )* 100) as Percentage_population_Infected 
		from [portfolio_project].[dbo].[covid_death]
			group by location,population 
				order by Percentage_population_Infected desc;



-- looking at the country with the Highest_death_count per population.

select location , max(cast(total_deaths as int)) as Highest_death_count
	from [portfolio_project].[dbo].[covid_death]
		where continent is null 
			group by location
				order by Highest_death_count desc;


--Showing the results using CONTINENTS.

select location, max(cast(total_deaths as int)) as Highest_death_count
	from [portfolio_project].[dbo].[covid_death]
		where continent is  null 
			group by location
				order by Highest_death_count desc;

-- Showing the GLOBAL NUMBERS. 

select date ,sum(new_cases) as 'Total cases', sum(cast(new_deaths as int)) as 'Total deaths'
	from [portfolio_project].[dbo].[covid_death]
		where continent is not null
			group by date
				order by 'Total cases'  desc;


-- Showing the GLOBAL DEATH PERCENTAGE.

select date ,sum(new_cases) as 'Total cases', sum(cast(new_deaths as int)) as 'Total deaths'
,sum(cast(new_deaths as int)) /sum(new_cases) * 100 as Death_Percentage
	from [portfolio_project].[dbo].[covid_death]
		where continent is not null
			group by date
				order by 'Total cases'  desc;

-- Joining the two tables. 

select * from [portfolio_project].[dbo].[vacination] vac 
join [portfolio_project].[dbo].[covid_death] dea
on dea.location = vac.location
and dea.date = vac.date ;

-- looking at Total population Vs Total Vacinations.

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [portfolio_project].[dbo].[vacination] vac 
join [portfolio_project].[dbo].[covid_death] dea
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 3 desc;

--Looking at the total peoples vaccinated over the time in each location.

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Total_people_vaccinated
from [portfolio_project].[dbo].[vacination] vac 
join [portfolio_project].[dbo].[covid_death] dea
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3 ;

--Looking at the Percentage of total peoples vaccinated over the time in each location.

-- Using CTE(Common table expression)

with PopvsVac(continent,location,date,population,new_vaccinations,Total_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Total_people_vaccinated
from [portfolio_project].[dbo].[vacination] vac 
join [portfolio_project].[dbo].[covid_death] dea
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
)
select * , (Total_people_vaccinated/population) * 100 as Percentage_people_vacinated
from PopvsVac; 

-- Using Temp Table

Drop Table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_people_vaccinated numeric
)
Insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Total_people_vaccinated
from [portfolio_project].[dbo].[vacination] vac 
join [portfolio_project].[dbo].[covid_death] dea
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

select * , (Total_people_vaccinated/population) * 100 as Percentage_people_vacinated
from #percent_population_vaccinated; 


-- Creating View to store data for later visualization

create view percent_population_vaccinated_view as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Total_people_vaccinated
from [portfolio_project].[dbo].[vacination] vac 
join [portfolio_project].[dbo].[covid_death] dea
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
;

select * from percent_population_vaccinated_view;