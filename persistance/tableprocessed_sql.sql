use VeridionSupplierMaster

insert into Processed.Companies (
    VeridionID, 
    CompanyName, 
    CompanyLegalNames, 
    CompanyCommercialNames, 
    CompanyType, 
    YearFounded, 
    Revenue, 
    EmployeeCount, 
    MainIndustry, 
    ShortDescription, 
    LongDescription
)
select distinct
    veridion_id, 
    company_name, 
    company_legal_names, 
    company_commercial_names, 
    company_type, 
    TRY_CONVERT(INT, year_founded), 
    revenue, -- îl lăsăm string dacă în Processed e VARCHAR, sau convertim
    TRY_CONVERT(INT, employee_count),
    main_industry,
    short_description,
    long_description
from staging.Companies
WHERE veridion_id IS NOT NULL;

select * from Processed.Companies

delete from Processed.Companies

insert into Processed.Companies (
    VeridionID, CompanyName, CompanyLegalNames, CompanyCommercialNames, 
    CompanyType, YearFounded, Revenue, RevenueType, EmployeeCount, 
    EmployeeCountType, MainBusinessCategory, MainIndustry, MainSector, 
    ShortDescription, LongDescription, GeneratedDescription
)
select distinct 
    veridion_id, 
    MAX(company_name), -- Folosim MAX pentru a asigura un singur rand per ID
    MAX(company_legal_names),
    MAX(company_commercial_names),
    MAX(company_type),
    MAX(TRY_CONVERT(INT, year_founded)),
    MAX(revenue),
    MAX(revenue_type),
    MAX(TRY_CONVERT(INT, employee_count)),
    MAX(employee_count_type),
    MAX(main_business_category),
    MAX(main_industry),
    MAX(main_sector),
    MAX(short_description),
    MAX(long_description),
    MAX(generated_description)
from Staging.Companies
WHERE veridion_id IS NOT NULL
GROUP BY veridion_id; -- Ne asiguram ca avem un singur VeridionID unic

select * from Processed.Companies;

delete from Processed.InputRequests;

insert into processed.inputrequests (
    inputrowkey, veridionid, inputcompanyname, inputmaincountrycode, 
    inputmaincountry, inputmainregion, inputmaincity, inputmainpostcode, 
    inputmainstreet, inputmainstreetnumber
)
select distinct
    input_row_key, 
    veridion_id, 
    input_company_name, 
    main_country_code, 
    main_country, 
    main_region, 
    main_city, 
    main_postcode, 
    main_street, 
    main_street_number
from staging.companies
WHERE input_row_key is not null;

insert into processed.locations (
    veridionid, ismainlocation, countrycode, country, region, city, 
    postcode, street, streetnumber, latitude, longitude
)
select distinct
    veridion_id, 
    1, 
    main_country_code, 
    main_country, 
    main_region, 
    main_city, 
    main_postcode, 
    main_street, 
    main_street_number,
    try_convert(float, main_latitude),
    try_convert(float, main_longitude)
from staging.companies;


--modific marimea: 
alter table processed.locations alter column streetnumber nvarchar(max);
alter table processed.locations alter column postcode nvarchar(255);
alter table processed.locations alter column street nvarchar(max);
alter table processed.inputrequests alter column inputmainstreetnumber nvarchar(max);
alter table processed.inputrequests alter column inputmainpostcode nvarchar(255);
alter table processed.inputrequests alter column inputmainstreet nvarchar(max);

-- 
-- curățăm totul înainte de un nou import
truncate table processed.companytags;
truncate table processed.companyclassifications;
truncate table processed.onlinepresence;
truncate table processed.contactinfo;
truncate table processed.locations;
-- dezactivăm constrângerea de FK temporar pentru a putea goli inputrequests și companies
delete from processed.inputrequests;
delete from processed.companies;
go

-- 1. companii (tabelul părinte)
insert into processed.companies (
    veridionid, companyname, companylegalnames, companycommercialnames, 
    companytype, yearfounded, revenue, revenuetype, employeecount, 
    employeecounttype, mainbusinesscategory, mainindustry, mainsector, 
    shortdescription, longdescription, generateddescription
)
select 
    veridion_id, 
    max(company_name), 
    max(company_legal_names), 
    max(company_commercial_names),
    max(company_type), 
    max(try_convert(int, year_founded)), 
    max(revenue), 
    max(revenue_type),
    max(try_convert(int, employee_count)), 
    max(employee_count_type), 
    max(main_business_category),
    max(main_industry), 
    max(main_sector), 
    max(short_description), 
    max(long_description), 
    max(generated_description)
from staging.companies
where veridion_id is not null and veridion_id <> ''
group by veridion_id;

-- 2. input requests (datele de la client)
-- folosim group by pe input_row_key pentru a evita eroarea ta (PK violation pe valoarea 0)
insert into processed.inputrequests (
    inputrowkey, veridionid, inputcompanyname, inputmaincountrycode, 
    inputmaincountry, inputmainregion, inputmaincity, inputmainpostcode, 
    inputmainstreet, inputmainstreetnumber
)
select 
    input_row_key, 
    max(veridion_id), 
    max(input_company_name), 
    max(main_country_code), 
    max(main_country), 
    max(main_region), 
    max(main_city), 
    max(main_postcode), 
    max(main_street), 
    max(main_street_number)
from staging.companies
where input_row_key is not null
group by input_row_key;

-- 3. locations (locația principală)
insert into processed.locations (
    veridionid, ismainlocation, countrycode, country, region, city, 
    postcode, street, streetnumber, latitude, longitude
)
select distinct
    veridion_id, 1, main_country_code, main_country, main_region, main_city, 
    main_postcode, main_street, main_street_number,
    try_convert(float, main_latitude), try_convert(float, main_longitude)
from staging.companies
where veridion_id is not null;

-- 4. contact info (telefoane și email-uri)
insert into processed.contactinfo (veridionid, contacttype, contactvalue)
select distinct veridion_id, 'primary phone', primary_phone 
from staging.companies where primary_phone is not null and primary_phone <> '';

insert into processed.contactinfo (veridionid, contacttype, contactvalue)
select distinct veridion_id, 'primary email', primary_email 
from staging.companies where primary_email is not null and primary_email <> '';

-- 5. online presence
insert into processed.onlinepresence (veridionid, websiteurl, facebookurl, linkedinurl)
select distinct veridion_id, website_url, facebook_url, linkedin_url
from staging.companies where veridion_id is not null;

--am link de url mai lung decat ceea ce am stabilit eu: 

alter table processed.onlinepresence alter column websiteurl nvarchar(max);
alter table processed.onlinepresence alter column facebookurl nvarchar(max);
alter table processed.onlinepresence alter column linkedinurl nvarchar(max);
alter table processed.onlinepresence alter column twitterurl nvarchar(max);
alter table processed.onlinepresence alter column instagramurl nvarchar(max);
go

-- golim tabelele afectate
truncate table processed.onlinepresence;
go

-- rulăm insert-ul pentru online presence
insert into processed.onlinepresence (veridionid, websiteurl, facebookurl, linkedinurl)
select distinct 
    veridion_id, 
    website_url, 
    facebook_url, 
    linkedin_url
from staging.companies 
where veridion_id is not null and veridion_id <> '';

-- 6. classifications
insert into processed.companyclassifications (veridionid, systemtype, code, label)
select distinct veridion_id, 'naics_2022_primary', naics_2022_primary_code, naics_2022_primary_label
from staging.companies where naics_2022_primary_code is not null and naics_2022_primary_code <> '';

-- 7. tags
insert into processed.companytags (veridionid, tagtype, tagvalue)
select distinct veridion_id, 'regular', trim(value)
from staging.companies 
cross apply string_split(business_tags, '|')
where business_tags <> '' and veridion_id is not null;

select * from Processed.Companies
select * from Processed.CompanyClassifications
select * from Processed.CompanyTags
select * from Processed.ContactInfo
select * from Processed.InputRequests
select * from Processed.Locations
select * from Processed.OnlinePresence