{{ config(
        tags = ['dunesql'],
        alias = alias('agg_day'),
        materialized ='incremental',
        file_format ='delta',
        incremental_strategy='merge',
        unique_key = ['day', 'wallet_address', 'token_address']
        )
}}

select
    tr.blockchain,
    CAST(date_trunc('day', tr.evt_block_time) as date) as day,
    tr.wallet_address,
    tr.token_address,
    t.symbol,
    sum(tr.amount_raw) as amount_raw,
    sum(tr.amount_raw / power(10, t.decimals)) as amount
FROM 
{{ ref('transfers_optimism_erc20') }} tr
LEFT JOIN 
{{ ref('tokens_optimism_erc20') }} t on t.contract_address = tr.token_address
{% if is_incremental() %}
-- this filter will only be applied on an incremental run
WHERE tr.evt_block_time >= date_trunc('day', now() - interval '7' Day)
{% endif %}
GROUP BY 1, 2, 3, 4, 5