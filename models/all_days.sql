{# This example use of a dbt-utils macro shows the date_spine functionality where you can get a list od dates sepearated by day.#}
{{
    dbt_utils.date_spine(
        datepart = "day",
        start_date = "to_date('01/01/2022', 'mm/dd/yyy')",
        end_date = "dateadd(week, 1, current_date)"
    )
}}