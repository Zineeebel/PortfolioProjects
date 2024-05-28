--Looking at total population vs vaccination

SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
WHERE dea.continent is NOT NULL
-- ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated * 100.0 /population)
FROM PopvsVac

-- Temp table
DROP TABLE if EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR (255),
    LOCATION NVARCHAR (255),
    DATE DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
-- WHERE dea.continent is NOT NULL
-- ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated * 100.0 /population)
FROM #PercentPopulationVaccinated


-- Creating View to store data later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.[location]=vac.[location]
    AND dea.[date]= vac.[date]
WHERE dea.continent is NOT NULL
--ORDER BY 2,3