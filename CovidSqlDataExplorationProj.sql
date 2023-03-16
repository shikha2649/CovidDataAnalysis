/*Data set for covid deaths */

Select location,`date`,total_cases ,new_cases ,total_deaths ,population  from CovidDeaths cd 
order by 1,2;

/* total cases vs total deaths */

Select location,`date`,total_cases,total_deaths, concat(round((total_deaths /total_cases)*100),'%') as death_percentage from CovidDeaths cd 
where location = "India"
order by 5 desc;


/* Total cases vs the Population */

Select location,`date`,total_cases ,population, (total_cases/population)*100 as infection_percentage from CovidDeaths cd 
where location = "India"
order by 1,2;

/* Country with highest infection rates in ratio of population  */

Select location,max(total_cases) max_cases ,population, max((total_cases/population)*100) as infection_percentage from CovidDeaths cd 
#where location = "India"
group by location,population 
order by 4 desc;


# countries with highest percentage of death 

Select location,max(total_deaths) max_deaths ,population, max((total_deaths/population)*100) as death_percentage 
from CovidDeaths cd 
#where location = "India"
where continent is not null and LENGTH (continent) > 0
group by location,population 
order by 2 desc;


# continents with highest number of deaths 

select continent, max(total_deaths) as max_deaths 
from CovidDeaths cd 
where continent is NOT NULL and LENGTH (continent) > 0
group by continent 
order by 2 desc;

#Global analysis 

select 
#`date` ,
sum(new_cases) as total_new_cases , sum(new_deaths) as total_new_deaths , (sum(new_deaths)/sum(new_cases))*100 as death_percentage  
from CovidDeaths cd 
where continent != ''
#group by `date` 
order by 1;

select continent, sum(new_cases) as total_new_cases , sum(new_deaths) as total_new_deaths , (sum(new_deaths)/sum(new_cases))*100 as death_percentage  
from CovidDeaths cd 
where continent != ''
group by continent
order by 4 desc;



# total population vs the total vaccination 

select cd.location, cd.`date` , cd.continent , cd.population , cv.new_vaccinations 
from CovidDeaths cd join CovidVaccinations cv 
on cd.location = cv.location 
and cd.`date` = cv.`date`
where cd.continent != ''
#and cd.location = 'India'
order by 1,2;

# % vaccinated 

select cd.location, cd.`date` , cd.continent , cd.population , cv.new_vaccinations , 
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location , cd.`date`) as rolling_vac_count
#(cv.new_vaccinations/cd.population)* 100 Vac_percentage
from CovidDeaths cd join CovidVaccinations cv 
on cd.location = cv.location 
and cd.`date` = cv.`date`
where cd.continent != ''
#and cd.location = 'India'
order by 1,2;

with population_vacc (Location,`date` , continent, population, new_vaccinations , rolling_vac_count)
as 
(
select cd.location, cd.`date` , cd.continent , cd.population , cv.new_vaccinations , 
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location , cd.`date`) as rolling_vac_count
#(cv.new_vaccinations/cd.population)* 100 Vac_percentage
from CovidDeaths cd join CovidVaccinations cv 
on cd.location = cv.location 
and cd.`date` = cv.`date`
where cd.continent != ''
#and cd.location = 'India'
)
select *, (rolling_vac_count/population)*100 as percentage_vaccinated
from population_vacc;


# creating Views for visualization 

create view ContinentDeathPercentage
as 
select continent, sum(new_cases) as total_new_cases , sum(new_deaths) as total_new_deaths , (sum(new_deaths)/sum(new_cases))*100 as death_percentage  
from CovidDeaths cd 
where continent != ''
group by continent;

create view VaccinationPercentage 
as 
with population_vacc (Location,`date` , continent, population, new_vaccinations , rolling_vac_count)
as 
(
select cd.location, cd.`date` , cd.continent , cd.population , cv.new_vaccinations , 
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location , cd.`date`) as rolling_vac_count
#(cv.new_vaccinations/cd.population)* 100 Vac_percentage
from CovidDeaths cd join CovidVaccinations cv 
on cd.location = cv.location 
and cd.`date` = cv.`date`
where cd.continent != ''
#and cd.location = 'India'
)
select *, (rolling_vac_count/population)*100 as percentage_vaccinated
from population_vacc;


