{{
    config(
        tags=['dunesql', 'static'],
        schema = 'pangolin_avalanche_c',
        alias = alias('airdrop_claims'),
        materialized = 'table',
        file_format = 'delta',
        unique_key = ['recipient', 'tx_hash', 'evt_index'],
        post_hook='{{ expose_spells(\'["avalanche_c"]\',
                                "project",
                                "pangolin",
                                \'["hildobby"]\') }}'
    )
}}

{% set png_token_address = '0x60781c2586d68229fde47564546784ab3faca982' %}

WITH early_price AS (
    SELECT MIN(minute) AS minute
    , MIN_BY(price, minute) AS price
    FROM {{ source('prices', 'usd') }}
    WHERE blockchain = 'avalanche_c'
    AND contract_address= {{png_token_address}}
    )

SELECT 'avalanche_c' AS blockchain
, t.evt_block_time AS block_time
, t.evt_block_number AS block_number
, 'Pangolin' AS project
, 'Pangolin Airdrop' AS airdrop_identifier
, t.claimer AS recipient
, t.contract_address
, t.evt_tx_hash AS tx_hash
, t.amount AS amount_raw
, CAST(t.amount/POWER(10, 18) AS double) AS amount_original
, CASE WHEN t.evt_block_time >= (SELECT minute FROM early_price) THEN CAST(pu.price*t.amount/POWER(10, 18) AS double)
    ELSE CAST((SELECT price FROM early_price)*t.amount/POWER(10, 18) AS double)
    END AS amount_usd
, {{png_token_address}} AS token_address
, 'PNG' AS token_symbol
, t.evt_index
FROM {{ source('pangolin_exchange_avalanche_c', 'Airdrop_evt_PngClaimed') }} t
LEFT JOIN {{ ref('prices_usd_forward_fill') }} pu ON pu.blockchain = 'avalanche_c'
    AND pu.contract_address= {{png_token_address}}
    AND pu.minute=date_trunc('minute', t.evt_block_time)
WHERE t.evt_block_time BETWEEN timestamp '2021-02-09' AND timestamp '2021-03-10'