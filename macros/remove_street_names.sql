{#In this dbt project I don't actually have location data in more than one model,
but for my real job (whose data is a bit dicey to just share online), I work with location data all the time.
So making this macro as a POC could be very useful to me in the future, to remove street names from a crowded address field #}
{% macro remove_street_names(column_name) -%}

regexp_replace({{ column_name }}, '[a-zA-Z]', '')

{%- endmacro %}