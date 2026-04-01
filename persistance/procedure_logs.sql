use VeridionSupplierMaster;


create schema log;

create table log.logs (
    logid int identity(1,1) not null primary key,
    jobname nvarchar(255) null,        -- numele procesului (ex: 'import_veridion_data')
    status varchar(100) null,         -- 'in_lucru', 'succes', 'eroare'
    output_message varchar(max) null, -- am pus MAX pentru a capta TOATĂ eroarea dacă apare
    start_date datetime null default getdate(),
    end_date datetime null
);

select * from log.logs



create or alter procedure [staging].[loadcompaniesfromjson]
as
begin
    set nocount on;
    
    declare @current_log_id int;
    declare @jobname nvarchar(255) = 'veridion_upload_' + format(getdate(), 'yyyyMMdd_HHmmss');
    declare @json nvarchar(max);

    -- 1. inițializăm log-ul
    insert into log.logs (jobname, status, start_date)
    values (@jobname, 'in progress', getdate());
    
    set @current_log_id = scope_identity();

    begin try
        -- 2. citim fișierul json 
        select @json = bulkcolumn
        from openrowset(BULK 'D:\Paduaru Maria\project\presales_data_sample.json', single_clob) as j;

        begin transaction;

            -- 3. curatam staging-ul inainte de incarcare (opțional, dar recomandat)
            truncate table staging.companies;

            -- 4. insert în staging.companies (mapare pe structura veridion)
            insert into staging.companies (
                input_row_key, input_company_name, veridion_id, company_name, 
                company_legal_names, company_commercial_names, main_country, 
                main_country_code, main_region, main_city, main_postcode, 
                main_street, main_street_number, main_latitude, main_longitude,
                revenue, revenue_type, employee_count, employee_count_type,
                year_founded, company_type, main_business_category, main_industry,
                main_sector, naics_2022_primary_code, naics_2022_primary_label,
                naics_2022_secondary_codes, short_description, long_description,
                generated_description, primary_phone, phone_numbers,
                primary_email, emails, website_url, linkedin_url, facebook_url,
                locations, business_tags, generated_business_tags
            )
            select 
                input_row_key, input_company_name, veridion_id, company_name, 
                company_legal_names, company_commercial_names, main_country, 
                main_country_code, main_region, main_city, main_postcode, 
                main_street, main_street_number, main_latitude, main_longitude,
                revenue, revenue_type, employee_count, employee_count_type,
                year_founded, company_type, main_business_category, main_industry,
                main_sector, naics_2022_primary_code, naics_2022_primary_label,
                naics_2022_secondary_codes, short_description, long_description,
                generated_description, primary_phone, phone_numbers,
                primary_email, emails, website_url, linkedin_url, facebook_url,
                locations, business_tags, generated_business_tags
            from openjson(@json)
            with (
                input_row_key nvarchar(100)          '$.input_row_key',
                input_company_name nvarchar(max)     '$.input_company_name',
                veridion_id nvarchar(100)            '$.veridion_id',
                company_name nvarchar(max)           '$.company_name',
                company_legal_names nvarchar(max)    '$.company_legal_names',
                company_commercial_names nvarchar(max) '$.company_commercial_names',
                main_country nvarchar(255)           '$.main_country',
                main_country_code nvarchar(10)       '$.main_country_code',
                main_region nvarchar(255)            '$.main_region',
                main_city nvarchar(255)              '$.main_city',
                main_postcode nvarchar(100)          '$.main_postcode',
                main_street nvarchar(max)            '$.main_street',
                main_street_number nvarchar(100)     '$.main_street_number',
                main_latitude nvarchar(100)          '$.main_latitude',
                main_longitude nvarchar(100)         '$.main_longitude',
                revenue nvarchar(100)                '$.revenue',
                revenue_type nvarchar(100)           '$.revenue_type',
                employee_count nvarchar(100)         '$.employee_count',
                employee_count_type nvarchar(100)    '$.employee_count_type',
                year_founded nvarchar(50)            '$.year_founded',
                company_type nvarchar(255)           '$.company_type',
                main_business_category nvarchar(max) '$.main_business_category',
                main_industry nvarchar(max)          '$.main_industry',
                main_sector nvarchar(max)            '$.main_sector',
                naics_2022_primary_code nvarchar(100) '$.naics_2022_primary_code',
                naics_2022_primary_label nvarchar(max) '$.naics_2022_primary_label',
                naics_2022_secondary_codes nvarchar(max) '$.naics_2022_secondary_codes',
                short_description nvarchar(max)      '$.short_description',
                long_description nvarchar(max)       '$.long_description',
                generated_description nvarchar(max)  '$.generated_description',
                primary_phone nvarchar(100)          '$.primary_phone',
                phone_numbers nvarchar(max)          '$.phone_numbers',
                primary_email nvarchar(255)          '$.primary_email',
                emails nvarchar(max)                 '$.emails',
                website_url nvarchar(max)            '$.website_url',
                linkedin_url nvarchar(max)           '$.linkedin_url',
                facebook_url nvarchar(max)           '$.facebook_url',
                locations nvarchar(max)              '$.locations',
                business_tags nvarchar(max)          '$.business_tags',
                generated_business_tags nvarchar(max) '$.generated_business_tags'
            );

        commit transaction;

        -- 5. succes
        update log.logs
        set status = 'succeded', 
            end_date = getdate(),
            output_message = 'datele veridion au fost incarcate in staging cu succes. randuri: ' + cast(@@rowcount as varchar)
        where logid = @current_log_id;

    end try
    begin catch
        if @@trancount > 0 rollback transaction;

        update log.logs
        set status = 'failed', 
            end_date = getdate(),
            output_message = error_message()
        where logid = @current_log_id;

        throw;
    end catch
end
go

exec [Staging].[loadcompaniesfromjson]

select * from log.logs 
order by start_date desc;


insert into Log.Logs (jobname, status) VALUES ('test', 'ok')

select * from Staging.RawData

