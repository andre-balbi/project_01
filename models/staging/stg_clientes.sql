-- Teste de defer
with source as (
    select
    *
    from {{ source('ecommerce','clientes') }}
)

select
*
from source