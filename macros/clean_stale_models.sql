{% set database = target.database %}
{%- set schema = target.schema %}

{% macro clean_stale_models(database = target.database, schema = target.schema, days = 7) %}
    {% set query %}
    select
        table_type,
        table_schema,
        table_name,
        last_altered,
        case
            when table_type = 'VIEW'
            then table_type
        else
            'TABLE'
        end as drop_type,
        'DROP'|| drop_type || '{{ database | upper }}.' || table_schema || table_name || ';'
    from
        {{ database }}.information_schema.tables
    where table_schema = upper(' {{ schema }} ')
    and last_altered <= current_date - {{ days }}
    {% endset %}
    --the above generates a drop statement for any tables that haven't been modified in the last 7 days. it doesn't actually execute them. 

    --you have to actually set the drop queries and then loop through them and execute them. can have this be a post-hook!! 

    {{ log('\nGenerating cleanup queries...\n', info=True) }}
    {% set drop_queries = run_query(get_drop_commands_query).columns[1].values() %}

    {% for query in drop_queries %}
        {% if dry_run %}
            {{ log(query, info=True) }}
        {% else %}
            {{ log('Dropping object with command: ' ~ query, info=True) }}
            {% do run_query(query) %} 
        {% endif %}       
    {% endfor %}
{% endmacro %}