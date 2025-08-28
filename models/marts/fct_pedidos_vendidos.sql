{{
    config(
        tags=['vendas', 'fct', 'intermediate']
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