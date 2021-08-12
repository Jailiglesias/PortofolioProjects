/*
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///														Covid 19 Data Exploration														///
		///																															///
		/// Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types	///
		///																															///
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

																												Made By Jail Iglesias
*/


SELECT *
FROM Portofolio_Project..Covid_Deaths
WHERE continent	IS NOT NULL
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Portofolio_Project..Covid_Deaths
WHERE continent	IS NOT NULL
ORDER BY 1,2


-- Total cases vs total death in Argentina
-- Percentage of deaths

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM Portofolio_Project..Covid_Deaths
WHERE location = 'argentina'
ORDER BY 1,2 


-- Total Cases vs Population
-- Percentage of population infected with Covid in Arg

SELECT location,date,population, total_cases,(total_cases/population) * 100 AS Pop_Percentage
FROM Portofolio_Project..Covid_Deaths
WHERE location = 'argentina'
ORDER BY 1,2 


-- Countries with the highest degrees of infection by population

SELECT location,population,Max(total_cases) AS HighestInfectionCount, Max((total_cases/population)) * 100 AS Pop_Percentage
FROM Portofolio_Project..Covid_Deaths
WHERE continent	IS NOT NULL
GROUP BY location,population
ORDER BY Pop_Percentage DESC


-- Countries with the highest percentage of deaths

SELECT location,MAX(CAST(total_deaths AS INT)) AS Total_Deaths
FROM Portofolio_Project..Covid_Deaths
WHERE continent	IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths DESC


-- Continents with the highest percentage of deaths

SELECT location,MAX(CAST(total_deaths AS INT)) AS Total_Deaths
FROM Portofolio_Project..Covid_Deaths
WHERE continent	IS NULL
GROUP BY location
ORDER BY Total_Deaths DESC


--	Global Numbers by date

SELECT date,SUM(new_cases) AS Total_Cases,SUM(CAST(new_deaths AS INT)) AS Total_Deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM Portofolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 


-- Global Number 

SELECT SUM(new_cases) AS Total_Cases,SUM(CAST(new_deaths AS INT)) AS Total_Deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM Portofolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2 


/*


Joinning tables, Cte´s and Temp Tables


*/


-- Total vaccinated population (Cte)

WITH PopVsVac (Continent,Location,Date,Population,New_Vaccinations,PeopleVaccined_ByDay)
AS 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS PeopleVaccined_ByDay
FROM Portofolio_Project..Covid_Deaths dea
JOIN Portofolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *,(PeopleVaccined_ByDay/Population) * 100 AS PopVaccined
FROM PopVsVac


-- Total vaccinated population (Temp Table)

DROP TABLE IF EXISTS #PercentPopulationVaccined
CREATE TABLE #PercentPopulationVaccined
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccined_ByDay numeric
)


INSERT INTO #PercentPopulationVaccined
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccined_ByDay
FROM Portofolio_Project..Covid_Deaths dea
JOIN Portofolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(PeopleVaccined_ByDay/Population) * 100 AS PopVaccined
FROM #PercentPopulationVaccined


/*


Creating Views


*/

-- View Countries_MaxDeaths

CREATE VIEW Countries_MaxDeaths as
SELECT location,MAX(CAST(total_deaths AS INT)) AS Total_Deaths
FROM Portofolio_Project..Covid_Deaths
WHERE continent	IS NOT NULL
GROUP BY location
--ORDER BY Total_Deaths DESC


--View PercentPopVaccined

CREATE VIEW PercentPopVaccined as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccined_ByDay
FROM Portofolio_Project..Covid_Deaths dea
JOIN Portofolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL