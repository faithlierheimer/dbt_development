{%- macro union_tables_by_prefix(schema, prefix) -%}
    {%- set tables=dbt_utils.get_relations_by_prefix(schema = schema, prefix = prefix) -%}
    {% for table in tables %}
        {%- if not loop.first %}
            union all 
        {%- endif %}
        select * from {{ table.schema }}.{{ table.name }}
    {% endfor -%}
{%- endmacro -%}