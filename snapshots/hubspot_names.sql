{% snapshot hubspot_names %}

{{
    config(
      target_database='default',
      target_schema='default',
      unique_key='hubspot_id',

      strategy='check',
      check_cols = ['hubspot_id', 'hubspot_name'],
    )
}}

select * from {{ source('default', 'hubspot_names') }}

{% endsnapshot %}