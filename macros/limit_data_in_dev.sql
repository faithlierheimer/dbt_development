{% macro limit_data_in_dev(column_name, dev_days_of_data) %}
{% if target.name == 'default' %}
where {{ column_name }} >= date_add(current_timestamp, -{{ dev_days_of_data }})
{% endif %}
{% endmacro %}