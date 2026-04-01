use VeridionSupplierMaster;

create schema Staging;

create table Staging.RawData ( 
ID int primary key identity(1,1), 
JsonData nvarchar(max), --pt datele din json
LoadDate datetime DEFAULT(getdate())
)
select * from Staging.RawData -- tabel cu datele brute din fisierul de JSON - am avut fisier csv pe care l-am transformat in JSON cu Python

-- mai creez un tabel staging.Companies care va avea coloane proprii pentru fiecare informatie din fisierul de JSON

create table Staging.Companies (
    -- Identificatori unici
    veridion_id NVARCHAR(100),
    input_row_key NVARCHAR(100),
    
    -- Date despre Companie (Input vs Identificat)
    input_company_name NVARCHAR(MAX),
    company_name NVARCHAR(MAX),
    company_legal_names NVARCHAR(MAX),
    company_commercial_names NVARCHAR(MAX),
    
    -- Localizare (Main)
    main_country NVARCHAR(255),
    main_country_code NVARCHAR(10),
    main_region NVARCHAR(255),
    main_city NVARCHAR(255),
    main_postcode NVARCHAR(100),
    main_street NVARCHAR(MAX),
    main_street_number NVARCHAR(100),
    main_latitude NVARCHAR(100),
    main_longitude NVARCHAR(100),
    
    -- Date Financiare si Resurse Umane
    revenue NVARCHAR(100),
    revenue_type NVARCHAR(100),
    employee_count NVARCHAR(100),
    employee_count_type NVARCHAR(100),
    year_founded NVARCHAR(50),
    company_type NVARCHAR(255),
    
    -- Clasificari Industriale (Le punem pe cele mai importante)
    main_business_category NVARCHAR(MAX),
    main_industry NVARCHAR(MAX),
    main_sector NVARCHAR(MAX),
    naics_2022_primary_code NVARCHAR(100),
    naics_2022_primary_label NVARCHAR(MAX),
    naics_2022_secondary_codes NVARCHAR(MAX), -- Contine liste separate prin |
    
    -- Descrieri
    short_description NVARCHAR(MAX),
    long_description NVARCHAR(MAX),
    generated_description NVARCHAR(MAX),
    
    -- Contact si Online
    primary_phone NVARCHAR(100),
    phone_numbers NVARCHAR(MAX),
    primary_email NVARCHAR(255),
    emails NVARCHAR(MAX),
    website_url NVARCHAR(MAX),
    linkedin_url NVARCHAR(MAX),
    facebook_url NVARCHAR(MAX),
    
    -- Campuri complexe (Array-uri stocate ca string pentru moment)
    locations NVARCHAR(MAX), 
    business_tags NVARCHAR(MAX),
    generated_business_tags NVARCHAR(MAX),
    
    -- Audit
    LoadDate DATETIME DEFAULT(GETDATE())
);


select * from Staging.Companies

if object_id('Staging.Companies', 'U') is not null drop table Staging.Companies; --daca tab exista sa ii dea drop la tabel --o varianta buna daca nu ma intereseaza consistenta datelor 

create table Staging.Companies (
    -- Identificatori unici
    veridion_id NVARCHAR(100),
    input_row_key NVARCHAR(100),
    
    -- Date despre Companie (Input vs Identificat)
    input_company_name NVARCHAR(MAX),
    company_name NVARCHAR(MAX),
    company_legal_names NVARCHAR(MAX),
    company_commercial_names NVARCHAR(MAX),
    
    -- Localizare (Main)
    main_country NVARCHAR(255),
    main_country_code NVARCHAR(10),
    main_region NVARCHAR(255),
    main_city NVARCHAR(255),
    main_postcode NVARCHAR(100),
    main_street NVARCHAR(MAX),
    main_street_number NVARCHAR(100),
    main_latitude NVARCHAR(100),
    main_longitude NVARCHAR(100),
    
    -- Date Financiare si Resurse Umane
    revenue NVARCHAR(100),
    revenue_type NVARCHAR(100),
    employee_count NVARCHAR(100),
    employee_count_type NVARCHAR(100),
    year_founded NVARCHAR(50),
    company_type NVARCHAR(255),
    
    -- Clasificari Industriale (Le punem pe cele mai importante)
    main_business_category NVARCHAR(MAX),
    main_industry NVARCHAR(MAX),
    main_sector NVARCHAR(MAX),
    naics_2022_primary_code NVARCHAR(100),
    naics_2022_primary_label NVARCHAR(MAX),
    naics_2022_secondary_codes NVARCHAR(MAX), -- Contine liste separate prin |
    
    -- Descrieri
    short_description NVARCHAR(MAX),
    long_description NVARCHAR(MAX),
    generated_description NVARCHAR(MAX),
    
    -- Contact si Online
    primary_phone NVARCHAR(100),
    phone_numbers NVARCHAR(MAX),
    primary_email NVARCHAR(255),
    emails NVARCHAR(MAX),
    website_url NVARCHAR(MAX),
    linkedin_url NVARCHAR(MAX),
    facebook_url NVARCHAR(MAX),
    
    -- Campuri complexe (Array-uri stocate ca string pentru moment)
    locations NVARCHAR(MAX), 
    business_tags NVARCHAR(MAX),
    generated_business_tags NVARCHAR(MAX),
    
    -- Audit
    LoadDate DATETIME DEFAULT(GETDATE())
);
    ;
    --acum iau datele din fisierul json si le incarc in RawData: 

declare @json nvarchar(MAX);

select @json = BulkColumn
from OPENROWSET(BULK 'D:\Paduaru Maria\project\presales_data_sample.json', SINGLE_CLOB) AS j;
--insert into Staging.RawData (JsonData)
--values (@json);

--select * from Staging.RawData
INSERT INTO staging.Companies (
    veridion_id,
    input_row_key,
    input_company_name,
    company_name,
    company_legal_names,
    company_commercial_names,
    main_country,
    main_country_code,
    main_region,
    main_city,
    main_postcode,
    main_street,
    main_street_number,
    main_latitude,
    main_longitude,
    revenue,
    revenue_type,
    employee_count,
    employee_count_type,
    year_founded,
    company_type,
    main_business_category,
    main_industry,
    main_sector,
    naics_2022_primary_code,
    naics_2022_primary_label,
    naics_2022_secondary_codes,
    short_description,
    long_description,
    generated_description,
    primary_phone,
    phone_numbers,
    primary_email,
    emails,
    website_url,
    linkedin_url,
    facebook_url,
    locations,
    business_tags,
    generated_business_tags
    -- LoadDate are DEFAULT, deci nu il punem in INSERT
)
SELECT
    veridion_id,
    TRY_CONVERT(INT, input_row_key), -- Conversie in INT pentru cheia de rand
    input_company_name,
    company_name,
    company_legal_names,
    company_commercial_names,
    main_country,
    main_country_code,
    main_region,
    main_city,
    main_postcode,
    main_street,
    main_street_number,
    main_latitude, -- In staging le lasam ca text momentan
    main_longitude,
    revenue,
    revenue_type,
    employee_count,
    employee_count_type,
    year_founded,
    company_type,
    main_business_category,
    main_industry,
    main_sector,
    naics_2022_primary_code,
    naics_2022_primary_label,
    naics_2022_secondary_codes,
    short_description,
    long_description,
    generated_description,
    primary_phone,
    phone_numbers,
    primary_email,
    emails,
    website_url,
    linkedin_url,
    facebook_url,
    locations, -- Array-ul JSON ca text
    business_tags,
    generated_business_tags
FROM OPENJSON(@json)
WITH (
    -- Mapare exacta dupa cheile din fisierul JSON
    input_row_key NVARCHAR(100)          '$.input_row_key',
    input_company_name NVARCHAR(MAX)     '$.input_company_name',
    veridion_id NVARCHAR(100)            '$.veridion_id',
    company_name NVARCHAR(MAX)           '$.company_name',
    company_legal_names NVARCHAR(MAX)    '$.company_legal_names',
    company_commercial_names NVARCHAR(MAX) '$.company_commercial_names',
    main_country NVARCHAR(255)           '$.main_country',
    main_country_code NVARCHAR(10)       '$.main_country_code',
    main_region NVARCHAR(255)            '$.main_region',
    main_city NVARCHAR(255)              '$.main_city',
    main_postcode NVARCHAR(100)          '$.main_postcode',
    main_street NVARCHAR(MAX)            '$.main_street',
    main_street_number NVARCHAR(100)     '$.main_street_number',
    main_latitude NVARCHAR(100)          '$.main_latitude',
    main_longitude NVARCHAR(100)         '$.main_longitude',
    locations NVARCHAR(MAX)              '$.locations',
    company_type NVARCHAR(255)           '$.company_type',
    year_founded NVARCHAR(50)            '$.year_founded',
    revenue NVARCHAR(100)                '$.revenue',
    revenue_type NVARCHAR(100)           '$.revenue_type',
    employee_count NVARCHAR(100)         '$.employee_count',
    employee_count_type NVARCHAR(100)    '$.employee_count_type',
    generated_description NVARCHAR(MAX)  '$.generated_description',
    generated_business_tags NVARCHAR(MAX) '$.generated_business_tags',
    short_description NVARCHAR(MAX)      '$.short_description',
    long_description NVARCHAR(MAX)       '$.long_description',
    business_tags NVARCHAR(MAX)          '$.business_tags',
    naics_2022_primary_code NVARCHAR(100) '$.naics_2022_primary_code',
    naics_2022_primary_label NVARCHAR(MAX) '$.naics_2022_primary_label',
    naics_2022_secondary_codes NVARCHAR(MAX) '$.naics_2022_secondary_codes',
    main_business_category NVARCHAR(MAX) '$.main_business_category',
    main_industry NVARCHAR(MAX)          '$.main_industry',
    main_sector NVARCHAR(MAX)            '$.main_sector',
    primary_phone NVARCHAR(100)          '$.primary_phone',
    phone_numbers NVARCHAR(MAX)          '$.phone_numbers',
    primary_email NVARCHAR(255)          '$.primary_email',
    emails NVARCHAR(MAX)                 '$.emails',
    website_url NVARCHAR(MAX)            '$.website_url',
    linkedin_url NVARCHAR(MAX)           '$.linkedin_url',
    facebook_url NVARCHAR(MAX)           '$.facebook_url'
);

select * from Staging.Companies

