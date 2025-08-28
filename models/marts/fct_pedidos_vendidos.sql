{{
    config(
        tags=['vendas', 'fct']
    )
}}

with pedidos as (
    select
        *
    from {{ ref('int_pedidos_vendidos') }}
)

select
    *
from pedidos