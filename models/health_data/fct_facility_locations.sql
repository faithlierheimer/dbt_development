with phs_data as (select * from {{ ref('stg_phs_chicago') }}),

no_street_names as (
select 
    facility,
    street_address,
    {{ remove_street_names('street_address') }} without_street_names
from phs_data)

select * from no_street_names