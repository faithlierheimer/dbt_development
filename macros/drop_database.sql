{% macro drop_database(db_name, cascade=False, if_exists=True) %}
{% set sql %}
    drop schema{% if if_exists %} if exists{% endif %} {{ db_name }}{% if cascade %} cascade{% endif %}
{% endset %}

{% do run_query(sql) %}
{% do log("Database dropped: " ~ db_name, info=True) %}
{% endmacro %}