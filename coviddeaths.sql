select * from coviddeaths_recap;
select * from covidvaccine_recap;
-- looking the data we need
select location,`date`,population,total_cases,new_cases,total_deaths 
from coviddeaths2
order by 1,2;

-- death percentage  
select location,`date`,population,total_cases,total_deaths ,(total_deaths/total_cases)*100 as death_percentage
from coviddeaths_recap
order by death_percentage desc;

-- looking for infected people be location
select location,population,max(total_cases) as highestInfectedByLocation ,max(total_cases/population)*100 as death_percentage
from coviddeaths_recap
group by location,population
order by death_percentage desc;

-- looking for total deaths per location
select location,max(cast(total_deaths as unsigned)) as totalDeathCount
from coviddeaths_recap
where continent!=''
group by location
order by totalDeathcount desc;

-- looking for total deaths per continent
select continent ,max(cast(total_deaths as unsigned)) as totalDeathCount
from coviddeaths_recap
where continent!=''
group by continent
order by totalDeathcount desc;

-- looking global numbers
select sum(new_deaths) as totalDeaths, sum(new_cases) as totalCases ,
(sum(new_deaths)/sum(new_cases))*100 as totalDeathPercentage
from coviddeaths_recap
where continent!='';

-- looking people vaccinated against population
with PopVsVac (continent,date,location,population,new_vaccinations,rollingPeopleVaccinaed)
as(
select r1.continent,r1.date,r1.location,r1.population,r2.new_vaccinations,
sum(r2.new_vaccinations) over (partition by r1.location order by r1.location,r1.date) as rollingPeopleVaccinaed
-- (rollingPeopleVaccinaed/population)*100 as peopleVaccinatedPercentage
from coviddeaths_recap as r1
join covidvaccine_recap as r2 on  
r1.date=r2.date and 
r1.location=r2.location
where r1.continent!=''
-- order by location 
)
select *,(rollingPeopleVaccinaed/population)*100 as peopleVaccinatedPercentage from PopVsVac;

-- creating table
create table PeopleVaccinationpercentage
(continent varchar(200),
location varchar(200),
date text,
population text,
new_vaccinations text,
rollingPeopleVaccinaed text);


insert into PeopleVaccinationpercentage
select r1.continent,r1.date,r1.location,r1.population,r2.new_vaccinations,
sum(r2.new_vaccinations) over (partition by r1.location order by r1.location,r1.date) as rollingPeopleVaccinaed
-- (rollingPeopleVaccinaed/population)*100 as peopleVaccinatedPercentage
from coviddeaths_recap as r1
join covidvaccine_recap as r2 on  
r1.date=r2.date and 
r1.location=r2.location;
-- where r1.continent!='';
-- order by location 
select *,(rollingPeopleVaccinaed/population)*100 as peopleVaccinatedPercentage from PeopleVaccinationpercentage;