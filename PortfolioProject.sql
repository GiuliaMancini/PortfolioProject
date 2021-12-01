/*

I dati sono stati scaricati dal seguente sito: https://ourworldindata.org/covid-deaths
Da questi dati sono state create due tabelle: Covid Deaths e Covid Vaccinations.

\*
-- Seleziono i dati che userò in seguito

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths

-- Mostro la percentuale della popolazione che ha contratto il covid per quanto riguarda l'Italia

Select Location, date, population, total_deaths, total_cases, cast((total_cases/population)*100 as decimal(16,2)) as PercentualePopolazioneInfetta
from PortfolioProject..CovidDeaths
where location like '%Ital%'

-- Mostro quanti morti, quanti casi di Covid e la percentuale 
-- di persone morte tra chi ha preso il virus per ogni paese
-- Trovo la percentuale di morti tra i malati per ogni paese.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentualeMorti
from PortfolioProject..CovidDeaths

-- Uso group by -  mi da il numero masssimo della percentuale di morti
	 Select location, max(date) as data, max(cast(total_cases as decimal(36,2))) as casi, Max(cast(total_deaths as decimal(36,2))) as morti, max(cast((total_deaths/total_cases)*100 as decimal(16,2))) as PercentualeMortiMax
from CovidDeaths
where total_cases is not null and total_deaths is not null
	group by location
	order by location
--order by PercentualeMorti desc

-- Uso where 
	 Select location, date, cast(total_cases as decimal(36,2)) as casi, cast(total_deaths as decimal(36,2)) as morti, cast((total_deaths/total_cases)*100 as decimal(16,2)) as PercentualeMorti
from CovidDeaths
where total_cases is not null and total_deaths is not null and date = '2021-11-28T00:00:00.000' 
	order by location

-- Usando top 
Select top 209 location, date, cast(total_cases as decimal(36,2)) as casi, cast(total_deaths as decimal(36,2)) as morti, cast((total_deaths/total_cases)*100 as decimal(16,2)) as PercentualeMorti
from PortfolioProject..CovidDeaths
order by date desc, location 


-- Uso CTE e subquery
WITH CTE_CasiNonNulli as 
(
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentualeMorti,
	Rank() over (Partition by location order by date DESC) as allagrande
	from CovidDeaths where total_cases is not null and total_deaths is not null
)

Select rank.location, rank.date, total_cases, total_deaths, cast((total_deaths/total_cases)*100 as decimal(16,2)) as PercentualeMorti
from (
	Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentualeMorti,
	Rank() over (Partition by location order by date DESC) as allagrande
	from CTE_CasiNonNulli) rank
	where allagrande <= 1 
	

-- Mostro la percentuale di morti tra i malati IN ITALIA
WITH CTE_CasiNonNulli as 
(
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentualeMorti,
	Rank() over (Partition by location order by date DESC) as allagrande
	from CovidDeaths where total_cases is not null and total_deaths is not null
)

Select rank.location, rank.date, total_cases, total_deaths, cast((total_deaths/total_cases)*100 as decimal(16,2)) as PercentualeMorti
from (
	Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentualeMorti,
	Rank() over (Partition by location order by date DESC) as allagrande
	from CTE_CasiNonNulli) rank
	where allagrande <= 1 and location like '%Ital%'
	



-- Mostro i paesi con il più alto tasso di infezione rispetto alla popolazione totale

Select Location, population, MAX(total_cases) as MassimoNumeroCasi, max(cast((total_cases/population)*100 as decimal(16,2))) as PercentualePopolazioneInfetta
from PortfolioProject..CovidDeaths
-- where location like '%Ital%'
group by location, population
order by PercentualePopolazioneInfetta desc

-- Mostro i paesi con il più alto numero di morti per popolzione per ogni paese
Select Location, population, MAX(cast(total_deaths as int)) as TotaleMorti, max(cast((total_deaths/population)*100 as decimal(16,2))) as PercentualeMorti
from PortfolioProject..CovidDeaths
where continent<>''
group by location, population
order by TotaleMorti desc

-- Mostro i paesi con il più alto numero di morti per popolzione per ogni CONTINENTE
Select Location, population, MAX(cast(total_deaths as int)) as TotaleMorti, max(cast((total_deaths/population)*100 as decimal(16,2))) as PercentualeMorti
from PortfolioProject..CovidDeaths
where continent='' and location <>'High income' and location <>'Upper middle income' and location <>'Lower middle income' and location <>'Low income' and location <>'International'
group by location, population
order by TotaleMorti desc

-- Mostro il totale dei casi, morti e percentuale dei morti sui casi nel mondo diviso per data
Select date, SUM(new_cases) as totale_casi, SUM(cast(new_deaths as int)) as totale_morti, cast(SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as decimal(16,2)) as PercentualeMorti
From PortfolioProject..CovidDeaths
--Where location like '%Ital%'
where continent <> '' 
group By date
order by 1,2

-- Mostro il totale complessivo nel mondo di casi, morti  e relativa percentuale
Select SUM(new_cases) as totale_casi, SUM(cast(new_deaths as int)) as totale_morti, cast(SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as decimal(16,2)) as PercentualeMorti
From PortfolioProject..CovidDeaths
--Where location like '%Ital%'
where continent <> '' 
--Group By date
order by 1,2


-- Mostro il numero totale di persone nel mondo che sono state vaccinate


Select dea.continent, dea.location, dea.date, dea.population, TRY_CONVERT(decimal(38,0),vac.new_vaccinations) as NuoviVaccinati
, SUM(TRY_CONVERT(decimal(38,0),vac.new_vaccinations)) OVER (Partition by dea.continent Order by dea.location, dea.Date) as SommaProgressivaVaccinati
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent = '' and dea.location like '%World%'-- and dea.location like '%Euro%' 
order by 2,3

--- Mostro il numero totale di persone nel mondo che sono state vaccinate divise per paese
Select dea.continent, dea.location, dea.date, dea.population, TRY_CONVERT(decimal(38,0),vac.new_vaccinations) as NuoviVaccinati
, SUM(TRY_CONVERT(decimal(38,0),vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as SommaProgressivaVaccinati
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null -- and dea.location like 'Ita%' 
order by 2,3

-- Uso la CTE per mostrare anche la percentuale dei vaccinati rispetto alla popolazione

With CTE_PercentualeVaccinati (Continent, Location, Date, Population, New_Vaccinations, SommaProgressivaVaccinati)
as
(
Select dea.continent, dea.location, dea.date, dea.population, TRY_CONVERT(decimal(38,0),vac.new_vaccinations) as NuoviVaccinati
, SUM(TRY_CONVERT(decimal(38,0),vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as SommaProgressivaVaccinati
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and dea.location like 'Ita%' 
)
Select *, CONVERT(decimal(38,2),(SommaProgressivaVaccinati/Population)*100) as PercentualeVaccinati
From CTE_PercentualeVaccinati



-- Uso Temp Table per mostrare anche la percentuale dei vaccinati rispetto alla popolazione

DROP Table if EXISTS #PercentualeVaccinati
Create Table #PercentualeVaccinati
(
Continenti nvarchar(255),
Luogo nvarchar(255),
Data datetime,
Popolazione numeric,
NuoviVaccinati numeric,
SommaProgressivaVaccinati numeric
)

Insert into #PercentualeVaccinati
Select dea.continent, dea.location, dea.date, dea.population, TRY_CONVERT(decimal(38,0),vac.new_vaccinations) as NuoviVaccinati
, SUM(TRY_CONVERT(decimal(38,0),vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as SommaProgressivaVaccinati
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''-- and dea.location like 'Ita%' 

Select *, TRY_CONVERT(decimal(38,2),(SommaProgressivaVaccinati/Popolazione)*100) as PercentualeVaccinati
From #PercentualeVaccinati
order by continenti, luogo 




-- Creo una View per visualizzare i dati successivamente 

Create View PercentualeVaccinati as

Select dea.continent, dea.location, dea.date, dea.population, TRY_CONVERT(decimal(38,0),vac.new_vaccinations) as NuoviVaccinati
, SUM(TRY_CONVERT(decimal(38,0),vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as SommaProgressivaVaccinati
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''-- and dea.location like 'Ita%'  

Select*
From PercentualeVaccinati