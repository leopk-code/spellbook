{{ config(
    schema = 'tokens_ethereum',
    alias = 'balances',
    materialized = 'view',
    tags = ['prod_exclude']
    )
}}

{{
    balances_enrich(
        balances_base = source('tokens_ethereum', 'balances_ethereum_0002'),
        blockchain = 'ethereum',
    )
}}
