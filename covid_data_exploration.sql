CREATE DATABASE portfolioProject;

CREATE TABLE covid_deaths(
  id SERIAL,
  iso_code CHAR(3),
  continent VARCHAR(50),
  location VARCHAR(100),
  date DATE,
  population BIGINT,
  total_cases BIGINT,
  new_cases BIGINT,
  new_cases_smoothed DECIMAL(15,5),
  total_deaths BIGINT,
  new_deaths BIGINT,
  new_deaths_smoothed DECIMAL(15,5),
  total_cases_per_million DECIMAL(15,5),
  new_cases_per_million DECIMAL(15,5),
  new_cases_smoothed_per_million DECIMAL(15,5),
  total_deaths_per_million DECIMAL(15,5),
  new_deaths_per_million DECIMAL(15,5),
  new_deaths_smoothed_per_million DECIMAL(15,5),
  reproduction_rate DECIMAL(8,5),
  icu_patients BIGINT,
  icu_patients_per_million DECIMAL(15,5),
  hosp_patients BIGINT,
  hosp_patients_per_million DECIMAL(15,5),
  weekly_icu_admissions DECIMAL(15,5),
  weekly_icu_admissions_per_million DECIMAL(15,5),
  weekly_hosp_admissions DECIMAL(15,5),
  weekly_hosp_admissions_per_million DECIMAL(15,5),
);

CREATE TABLE covid_vaccinations(
  id SERIAL,
  iso_code CHAR(3),
  continent VARCHAR(50),
  location VARCHAR(100),
  date DATE,
  new_tests BIGINT,
  total_tests BIGINT,
  total_tests_per_thousand DECIMAL(15,5),
  new_tests_per_thousand DECIMAL(15,5),
  new_tests_smoothed DECIMAL(15,5),
  new_tests_smoothed_per_thousand DECIMAL(15,5),
  positive_rate DECIMAL(8,5),
  tests_per_case DECIMAL(15,5),
  tests_units VARCHAR(100),
  total_vaccinations BIGINT,
  people_vaccinated BIGINT,
  people_fully_vaccinated BIGINT,
  new_vaccinations BIGINT,
  new_vaccinations_smoothed DECIMAL(15,5),
  total_vaccinations_per_hundred DECIMAL(15,5),
  people_vaccinated_per_hundred DECIMAL(15,5),
  people_fully_vaccinated_per_hundred DECIMAL(15,5),
  new_vaccinations_smoothed_per_million DECIMAL(15,5),
  stringency_index DECIMAL(8,5),
  population_density DECIMAL(8,5),
  median_age DECIMAL(8,5),
  aged_65_older DECIMAL(8,5),
  aged_70_older DECIMAL(8,5),
  gdp_per_capita DECIMAL(12,5),
  extreme_poverty DECIMAL(8,5),
  cardiovasc_death_rate DECIMAL(9,5),
  diabetes_prevalence DECIMAL(8,5),
  female_smokers DECIMAL(8,5),
  male_smokers DECIMAL(8,5),
  handwashing_facilities DECIMAL(8,5),
  hospital_beds_per_thousand DECIMAL(15,5),
  life_expectancy DECIMAL(8,5),
  human_development_index DECIMAL(6,5),
  excess_mortality DECIMAL(8,5),
);


-- QUERIES:

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
FROM covid_deaths
-- WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases::DOUBLE PRECISION) AS highest_infection_count, MAX(total_cases::DOUBLE PRECISION/population)*100 AS percent_population_infected
FROM covid_deaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY percent_population_infected DESC NULLS LAST;

-- Showing Countries wiht Highest Death Count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
-- WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From covid_deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by total_death_count desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From covid_deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
From covid_deaths dea
INNER JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;

-- USE CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) 
AS
(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
  --, (rolling_people_vaccinated/population)*100
  From covid_deaths dea
  INNER JOIN covid_vaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
  WHERE dea.continent is not null 
  ORDER BY 2,3
)

SELECT * FROM pop_vs_vac



WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_people_vaccinated
  --, (rolling_people_vaccinated/population)*100
  From covid_deaths dea
  Join covid_vaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
  where dea.continent is not null 
  --order by 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
  continent VARCHAR(255),
  location VARCHAR(255),
  date datetime,
  population BIGINT,
  new_vaccinations INTEGER,
  rolling_people_vaccinated INTEGER,
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
From covid_deaths dea
Join covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #rolling_people_vaccinated
