{% macro grant_privileges(tbl) %}
{% set sql_owner %}
    ALTER TABLE {{ tbl }} OWNER TO `data-engineering`
{% endset %}
{% set sql_grant_all %}
    GRANT ALL PRIVILEGES ON TABLE {{ tbl }} TO `data-science`
{% endset %}
{% set sql_grant_read %}
    GRANT SELECT, READ_METADATA ON TABLE {{ tbl }} TO `report-viewers`
{% endset %}

{% if not target.schema.startswith("dbt_") %}
    {% do run_query(sql_owner) %}
    {% do run_query(sql_grant_all) %}
    {% do run_query(sql_grant_read) %}
{% endif %}
{% endmacro %}