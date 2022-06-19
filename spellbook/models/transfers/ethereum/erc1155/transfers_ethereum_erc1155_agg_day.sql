{{ config(
        alias ='erc1155_agg_day',
        materialized ='incremental'
        )
}}

select
    'ethereum' as blockchain,
    date_trunc('day', evt_block_time) as day,
    wallet_address,
    token_address,
    tokenId,
    sum(amount) as amount,
    unique_tx_id || '-' || wallet_address || '-' || token_address || tokenId || '-' || sum(amount)::string as unique_transfer_id
FROM {{ ref('transfers_ethereum_erc1155') }}
{% if is_incremental() %}
-- this filter will only be applied on an incremental run
where evt_block_time > now() - interval 2 days
{% endif %}
group by
    date_trunc('day', evt_block_time), wallet_address, token_address, tokenId, unique_tx_id