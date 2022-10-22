{% macro create_database(db_name, owner='data-engineering', comment='Created via DBT create_database operation', ignore_existing=False) %}
{% set sql_create %}
    create schema {{ db_name }} comment '{{ comment }}'
{% endset %}

{% set sql_owner %}
    alter schema {{ db_name }} owner to `{{ owner }}`
{% endset %}

{% set sql_grant %}
    grant all privileges on schema {{ db_name }} to `{{ owner }}`
{% endset %}

{% set should_run = True %}
{% if ignore_existing %}
    {% set sql_check %}
        show schemas like '{{ db_name }}'
    {% endset %}

    {% set results = run_query(sql_check) %}
    {% set should_run = (results.rows[0] is not defined) %}
{% endif %}

{% if should_run %}
    {% do run_query(sql_create) %}
    {% do run_query(sql_owner) %}
    {% do run_query(sql_grant) %}
    {% do log("Database created: " ~ db_name, info=True) %}
{% else %}
    {% do log("Skipping: database already exists", info=True) %}
{% endif %}
{% endmacro %}