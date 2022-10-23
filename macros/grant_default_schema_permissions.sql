{% macro grant_default_schema_permissions(schemas, keep_owner=False) %}
    {% for schema in schemas %}
        {% if not keep_owner %}
            {% set sql %}
                alter schema {{ schema }} owner to `data-engineering`
            {% endset %}
            {% do run_query(sql) %}
        {% endif %}

        {% set sql %}
            grant select, usage, read_metadata on schema {{ schema }} to `data-science`
        {% endset %}
        {% do run_query(sql) %}

        {% set sql %}
            grant select, usage, read_metadata on schema {{ schema }} to `report-viewers`
        {% endset %}
        {% do run_query(sql) %}
    {% endfor %}
{% endmacro %}