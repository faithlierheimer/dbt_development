{% macro calculate_running_total(value_col, partition_col) %}
    sum( {{ value_col }} ) over (order by {{ partition_col }})
{% endmacro %}