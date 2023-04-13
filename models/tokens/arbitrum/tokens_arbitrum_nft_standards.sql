{{ config(
        alias ='nft_standards',
        materialized='incremental',
	    incremental_strategy = 'merge',
        file_format = 'delta',
        unique_key = ['contract_address']
)
}}

 SELECT
  t.contract_address
, max_by(t.token_standard, t.block_time) AS standard
FROM {{ ref('nft_arbitrum_transfers') }} t
    {% if is_incremental() %}
       WHERE t.block_time >= date_add('week', -1, CURRENT_TIMESTAMP(6))
    {% endif %}
GROUP BY 1
