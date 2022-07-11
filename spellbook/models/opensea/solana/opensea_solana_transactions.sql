{{ config(
        alias ='transactions',
        materialized ='incremental',
        file_format ='delta',
        incremental_strategy='merge',
        unique_key='unique_trade_id'
        )
}}

SELECT 
  'solana' as blockchain,
  'opensea' as project,
  'v1' as version,
  signatures[0] as tx_hash, 
  block_time,
  abs(post_balances[0] / 1e9 - pre_balances[0] / 1e9) * p.price AS amount_usd,
  abs(post_balances[0] / 1e9 - pre_balances[0] / 1e9) AS amount_original,
  abs(post_balances[0] - pre_balances[0])::string AS amount_raw,
  p.symbol as currency_symbol,
  p.contract_address as currency_contract,
  'metaplex' as token_standard,
  CASE WHEN (array_contains(account_keys, '3o9d13qUvEuuauhFrVom1vuCzgNsJifeaBYDPquaT73Y')) THEN '3o9d13qUvEuuauhFrVom1vuCzgNsJifeaBYDPquaT73Y'
  WHEN (array_contains(account_keys, 'pAHAKoTJsAAe2ZcvTZUxoYzuygVAFAmbYmJYdWT886r')) THEN 'pAHAKoTJsAAe2ZcvTZUxoYzuygVAFAmbYmJYdWT886r' 
  END as project_contract_address,
  'Trade' as evt_type,
  signatures[0] || '-' || id as unique_trade_id
FROM {{ source('solana','transactions') }}
LEFT JOIN {{ source('prices', 'usd') }} p 
  ON p.minute = date_trunc('minute', block_time)
  AND p.symbol = 'SOL'
WHERE (array_contains(account_keys, '3o9d13qUvEuuauhFrVom1vuCzgNsJifeaBYDPquaT73Y')
       OR array_contains(account_keys, 'pAHAKoTJsAAe2ZcvTZUxoYzuygVAFAmbYmJYdWT886r'))
AND block_date > '2022-04-06'
AND block_slot > 128251864

{% if is_incremental() %}
-- this filter will only be applied on an incremental run
AND block_date > now() - interval 2 days
{% endif %} 