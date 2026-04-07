
-- vreau sa identific daca exista date lipsa in baza de date: 

select *
from Processed.Companies as c 
JOIN Processed.Locations as l ON c.VeridionID=l.VeridionID

select * from Processed.Companies
select * from Processed.Locations

-- 1. Verific daca exista companii care NU au nicio locatie marcată ca fiind principala
-- sau care au MAI MULTE locații 


--JOIN simplu, daca o companie are 5 locații, vor fi 5 rânduri pentru acel VeridionID. Fac verificarea atributului IsMainLocation.
select 
    c.VeridionID, 
    c.CompanyName, 
    SUM(CASE WHEN IsMainLocation = 'true' THEN 1 ELSE 0 END) as MainLocationCount
from Processed.Companies as c
JOIN Processed.Locations as l ON c.VeridionID = l.VeridionID
GROUP BY c.VeridionID, c.CompanyName
HAVING SUM(CASE WHEN IsMainLocation = 'true' THEN 1 ELSE 0 END) <> 1;

-- nu am rezultate la aceasta verificare

-- 2. Analizăm calitatea datelor financiare și de mărime

-- 2. Analizăm calitatea datelor (Varianta cu tratare VARCHAR și Overflow)
SELECT 
    COUNT_BIG(*) as TotalRecords,
    SUM(CASE 
        WHEN Revenue IS NULL 
             OR Revenue = '' 
             -- convertesc la DECIMAL(38,0) pentru că valoarea e mult prea mare
             OR TRY_CAST(Revenue AS DECIMAL(38,0)) = 0 
        THEN CAST(1 AS BIGINT) ELSE 0 END) as MissingRevenue,
    SUM(CASE 
        WHEN EmployeeCount IS NULL 
             OR EmployeeCount = '' 
             OR TRY_CAST(EmployeeCount AS BIGINT) = 0 
        THEN CAST(1 AS BIGINT) ELSE 0 END) as MissingEmployeeCount,
    SUM(CASE 
        WHEN MainIndustry IS NULL OR MainIndustry = '' 
        THEN CAST(1 AS BIGINT) ELSE 0 END) as MissingIndustry
FROM Processed.Companies;

--deci avem missing: total records de 2716, missing revenue 1276, missing employee count 1192, missing industry 316 

-- 3. consistența CountryCode vs Country și adrese incomplete
SELECT 
    CountryCode, 
    Country, 
    COUNT(*) as Count
FROM Processed.Locations
WHERE City IS NULL OR Postcode IS NULL OR Street IS NULL
GROUP BY CountryCode, Country;


  SELECT CountryCode, Country, COUNT(*) as Count
FROM Processed.Locations
WHERE (City IS NULL OR City = '') 
   OR (Postcode IS NULL OR Postcode = '')
GROUP BY CountryCode, Country;

--interogările nu dau rezultate:

--În urma testelor de integritate, am observat următoarele puncte forte ale setului de date:

--Integritatea locațiilor: 100% din înregistrările analizate prezintă date geografice complete (Oraș, Cod Poștal, Stradă), nefiind identificate câmpuri vide.

--Bogăția conținutului: Toate entitățile de tip furnizor dispun de cel puțin o formă de descriere textuală, asigurând contextul necesar pentru utilizatorul final.

-- 4. Verificăm unde nu avem nicio formă de descriere (date "sărace")
SELECT VeridionID, CompanyName
FROM Processed.Companies
WHERE ShortDescription IS NULL 
  AND LongDescription IS NULL 
  AND GeneratedDescription IS NULL;

  SELECT VeridionID, CompanyName, ShortDescription
FROM Processed.Companies
WHERE LEN(ISNULL(ShortDescription, '')) < 10 -- Descrieri mai scurte de 10 caractere
   OR ShortDescription IN ('N/A', 'None', 'no-description');


   -- vreau sa vad daca exista randuri 'stricate'

   WITH ISOCodes AS (
    -- Aici definim standardul (Sursa de Adevăr)
    SELECT 'US' as Code, 'United States' as CorrectCountry UNION ALL
    SELECT 'DK', 'Denmark' UNION ALL
    SELECT 'FR', 'France' UNION ALL
    SELECT 'RO', 'Romania'
)
SELECT 
    l.VeridionID, 
    l.CountryCode, 
    l.Country AS OriginalCountry, 
    iso.CorrectCountry AS SuggestedCountry
FROM Processed.Locations l
JOIN ISOCodes iso ON l.CountryCode = iso.Code
WHERE l.Country != iso.CorrectCountry;

