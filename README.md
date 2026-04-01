# Supplier Master Data Management System

**Author:** Maria Păduraru  
**Project Type:** SQL Data Normalization & Entity Linking

## 📌 Project Overview
This project focuses on transforming flat, raw business data (CSV/Input requests) into a highly normalized relational database. The core objective is to manage **Supplier Master Data** by linking client input requests to a verified central entity database using a unique identifier (**VeridionID**).

The system is designed to handle complex data types such as social media presence, multi-industry classifications (NAICS/NACE/ISIC), and multi-contact information, ensuring data integrity and eliminating redundancy.

## 🏗️ Database Architecture (ERD)
The database follows a star-schema-like normalization approach to manage 1-to-many relationships effectively.

### Key Entities:
* **Companies (Main Table):** Stores core entity data (VeridionID, Revenue, Employee count, Founding year).
* **InputRequests:** Captures original client search data and maps it to a `VeridionID` after the matching process.
* **Locations:** Detailed geographical data including headquarters and secondary branches.
* **CompanyClassifications:** A centralized table for various industry standards (SICS, NAICS, NACE, ISIC, SIC).
* **ContactInfo & OnlinePresence:** Granular storage for phones, emails, and social media handles (Facebook, LinkedIn, etc.).

![Supplier Master Diagram](./SupplierMaster_diagram.png)

## 🛠️ Technical Features

### 1. Data Normalization
Instead of using single columns with pipe-separated values (`|`), the system breaks down complex arrays into related tables:
* **Industry Codes:** Stored via `Type | Code | Label` mapping.
* **Contacts:** Categorized by `Contact Type` (Primary Phone, Secondary Email, etc.).
* **Tags:** Individual business tags are extracted for better filtering and searchability.

### 2. Entity Linking (The VeridionID Logic)
The system uses the `VeridionID` as a bridge between messy input data and verified records:
* **Traceability:** Every client request is linked to a specific legal entity.
* **Deduplication:** Multiple different inputs (e.g., "Starbucks SRL" vs "Starbucks Romania") are resolved to a single unique `VeridionID`.
* **Integrity:** Foreign key constraints prevent the deletion of companies that have associated historical input requests.

### 3. Handling Complex Metadata
* **CompanyTags:** Efficiently lists business descriptors.
* **OnlinePresence:** Tracks TLDs, domains, and full URLs for social platforms.

## 🔍 Data Integrity Rules
* **Uniqueness:** Primary keys are enforced across all tables to prevent record duplication.
* **Mapping:** The `InputRequests` table uses `VeridionID` as a Foreign Key, allowing for NULL values when a search query fails to find a match in the master database.

## 🚀 Use Cases
* **B2B Lead Enrichment:** Cleaning and expanding simple company names into full profiles.
* **Supplier Risk Management:** Maintaining a single "Golden Record" for vendors.
* **Market Analysis:** Querying companies based on specific industrial classifications (e.g., "All companies with NACE code X").

---

### 💻 Technologies Used
* **SQL Server (T-SQL)**: For relational mapping and constraint enforcement.
* **Relational Design**: 3rd Normal Form (3NF) principles.
* **Data Architecture**: Entity Linking & Master Data Management (MDM) logic.