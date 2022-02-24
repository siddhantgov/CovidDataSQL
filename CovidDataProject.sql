-- Select and Browse Data We Will Be Using
SELECT * FROM covid_death;
SELECT * FROM covid_vaccinations;

SELECT location, date, total_cases, new_cases, SUM(total_deaths), population 
FROM covid_death
GROUP BY Location
ORDER BY Location;

-- Overall Mortality Rate By Country

SELECT location, date as date_of_update, population, max(total_cases), max(total_deaths), (max(total_deaths)/population)*100 as mortality_rate
FROM covid_death
WHERE continent not like ''
GROUP BY Location
ORDER BY mortality_rate ASC;

-- Overall Infection Rate By Country

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as infection_rate
FROM covid_death
WHERE continent not like ''
GROUP BY location, population
ORDER BY infection_rate ASC;

-- Total Deaths By Country

SELECT location, date as date_of_update, population, max(cast(total_cases as unsigned)) as TotalCases, max(cast(total_deaths as unsigned)) as TotalDeaths
FROM covid_death
WHERE continent NOT LIKE ''
GROUP BY Location
ORDER by TotalDeaths desc;

Select location, max(cast(total_cases as unsigned)) as HighestCasesReported
FROM covid_death
WHERE location like'asia'
GROUP BY Location;


-- Total Deaths By Continent

SELECT continent, date as date_of_update, max(cast(total_deaths as unsigned)) as TotalDeaths
FROM covid_death
WHERE continent NOT LIKE '' AND continent NOT LIKE 'true'
GROUP BY continent
ORDER BY TotalDeaths DESC;

UPDATE covid_death
SET continent = ''
WHERE location = 'Asia' or location = 'Europe' or location ='North America' or location = 'Africa' or location = 'Oceania' or location = 'South America';



-- Global Numbers

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (total_deaths/total_cases) * 100 as death_percentage
FROM covid_death
WHERE continent NOT LIKE '' AND total_deaths NOT LIKE '' AND total_cases NOT LIKE ''
GROUP BY date
ORDER BY DATE(date);

SELECT * from covid_death WHERE date = '1/30/2020' AND continent NOT LIKE'';
Select date
FROM covid_death
WHERE continent not like '';

-- Total population vs Vaccinations

SELECT covid_death.continent, covid_death.location, covid_death.date, covid_death.population, covid_vaccinations.new_vaccinations, 
SUM(cast(covid_vaccinations.new_vaccinations as unsigned)) 
OVER (Partition by covid_death.location order by covid_death.location, covid_death.date) as rolling_vaccinated_total,
(rolling_vaccinated_total/covid_death.population)*100 as percent_population_vaccinated
FROM covid_death
JOIN covid_vaccinations on covid_death.location = covid_vaccinations.location
AND covid_death.date = covid_vaccinations.date
WHERE covid_death.continent NOT LIKE ''
ORDER BY location ASC;


-- Creating a CTE (common table expression) for a temp result set to use

With PopvsVac (Continent, Location, date, Population, New_Vaccinations, rolling_vaccinated_total) as
(
SELECT covid_death.continent, covid_death.location, covid_death.date, covid_death.population, covid_vaccinations.new_vaccinations, 
SUM(cast(covid_vaccinations.new_vaccinations as unsigned)) 
OVER (Partition by covid_death.location order by covid_death.location, covid_death.date) as rolling_vaccinated_total
FROM covid_death
JOIN covid_vaccinations on covid_death.location = covid_vaccinations.location
AND covid_death.date = covid_vaccinations.date
WHERE covid_death.continent NOT LIKE ''
)
SELECT *, (rolling_vaccinated_total/Population)*100 FROM PopvsVac;


-- Creating Views to store data for later visualizations and exploration

CREATE VIEW PercentPopulationVaccinated as 
With PopvsVac (Continent, Location, date, Population, New_Vaccinations, rolling_vaccinated_total) as
(
SELECT covid_death.continent, covid_death.location, covid_death.date, covid_death.population, covid_vaccinations.new_vaccinations, 
SUM(cast(covid_vaccinations.new_vaccinations as unsigned)) 
OVER (Partition by covid_death.location order by covid_death.location, covid_death.date) as rolling_vaccinated_total
FROM covid_death
JOIN covid_vaccinations on covid_death.location = covid_vaccinations.location
AND covid_death.date = covid_vaccinations.date
WHERE covid_death.continent NOT LIKE ''
)
SELECT *, (rolling_vaccinated_total/Population)*100 FROM PopvsVac;

CREATE VIEW MortalityRateByCountry as
SELECT location, date as date_of_update, population, max(total_cases), max(total_deaths), (max(total_deaths)/population)*100 as mortality_rate
FROM covid_death
WHERE continent not like ''
GROUP BY Location
ORDER BY mortality_rate ASC;

CREATE VIEW InfectionRateByCountry as
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as infection_rate
FROM covid_death
WHERE continent not like ''
GROUP BY location, population
ORDER BY infection_rate ASC;