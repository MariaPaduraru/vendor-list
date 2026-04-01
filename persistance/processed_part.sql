drop table Processed.Input_Companies

-- 1. Tabelul Central: Companiile 
CREATE TABLE Processed.Companies (
    VeridionID VARCHAR(100) PRIMARY KEY, 
    CompanyName NVARCHAR(255) NOT NULL,
    CompanyLegalNames NVARCHAR(MAX),      
    CompanyCommercialNames NVARCHAR(MAX),
    CompanyType NVARCHAR(100),
    YearFounded INT,
    Revenue VARCHAR(50),                  
    RevenueType NVARCHAR(50),
    EmployeeCount INT,
    EmployeeCountType NVARCHAR(50),
    MainBusinessCategory NVARCHAR(255),
    MainIndustry NVARCHAR(255),
    MainSector NVARCHAR(255),
    ShortDescription NVARCHAR(MAX),
    LongDescription NVARCHAR(MAX),
    GeneratedDescription NVARCHAR(MAX)
);

CREATE TABLE Processed.InputRequests (
    InputRowKey VARCHAR(100) PRIMARY KEY, -- input_row_key
    VeridionID VARCHAR(100) NOT NULL,     -- Facem legatura cu compania gasita
    InputCompanyName NVARCHAR(255),
    InputMainCountryCode NVARCHAR(10),
    InputMainCountry NVARCHAR(100),
    InputMainRegion NVARCHAR(100),
    InputMainCity NVARCHAR(100),
    InputMainPostcode NVARCHAR(50),
    InputMainStreet NVARCHAR(255),
    InputMainStreetNumber NVARCHAR(50),
    CONSTRAINT FK_InputRequests_Companies FOREIGN KEY (VeridionID) REFERENCES Processed.Companies(VeridionID)
);

CREATE TABLE Processed.Locations (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    VeridionID VARCHAR(100) NOT NULL,
    IsMainLocation BIT NOT NULL DEFAULT 0, -- 1 daca e adresa principala, 0 pentru restul din array
    CountryCode NVARCHAR(10),
    Country NVARCHAR(100),
    Region NVARCHAR(100),
    City NVARCHAR(100),
    Postcode NVARCHAR(50),
    Street NVARCHAR(255),
    StreetNumber NVARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT,
    CONSTRAINT FK_Locations_Companies FOREIGN KEY (VeridionID) REFERENCES Processed.Companies(VeridionID)
);


CREATE TABLE Processed.ContactInfo (
    ContactID INT IDENTITY(1,1) PRIMARY KEY,
    VeridionID VARCHAR(100) NOT NULL,
    ContactType NVARCHAR(50) NOT NULL, -- Ex: 'Primary Phone', 'Additional Phone', 'Primary Email', 'Other Email'
    ContactValue NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_ContactInfo_Companies FOREIGN KEY (VeridionID) REFERENCES Processed.Companies(VeridionID)
);

 CREATE TABLE Processed.OnlinePresence (
    WebID INT IDENTITY(1,1) PRIMARY KEY,
    VeridionID VARCHAR(100) NOT NULL,
    WebsiteURL NVARCHAR(255),
    WebsiteDomain NVARCHAR(100),
    WebsiteTLD NVARCHAR(20),
    WebsiteLanguageCode NVARCHAR(10),
    FacebookURL NVARCHAR(255),
    LinkedInURL NVARCHAR(255),
    TwitterURL NVARCHAR(255),
    InstagramURL NVARCHAR(255),
    -- Poti adauga si alte retele sociale daca exista in CSV
    CONSTRAINT FK_OnlinePresence_Companies FOREIGN KEY (VeridionID) REFERENCES Processed.Companies(VeridionID)
);

CREATE TABLE Processed.CompanyClassifications (
    ClassificationID INT IDENTITY(1,1) PRIMARY KEY,
    VeridionID VARCHAR(100) NOT NULL,
    SystemType NVARCHAR(50) NOT NULL, -- Ex: 'NAICS_2022_Primary', 'NAICS_2022_Secondary', 'SICS_Industry', 'NACE_REV2', 'ISIC_V4', 'IBC_Insurance'
    Code NVARCHAR(50),
    Label NVARCHAR(MAX),
    CONSTRAINT FK_Classifications_Companies FOREIGN KEY (VeridionID) REFERENCES Processed.Companies(VeridionID)
);
CREATE TABLE Processed.CompanyTags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    VeridionID VARCHAR(100) NOT NULL,
    TagType NVARCHAR(50) NOT NULL, -- Ex: 'Generated', 'Regular'
    TagValue NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_CompanyTags_Companies FOREIGN KEY (VeridionID) REFERENCES Processed.Companies(VeridionID)
);

