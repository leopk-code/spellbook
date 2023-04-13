{{ config(
    schema = 'pancakeswap_v2_ethereum',
    alias = 'amm_trades',
    partition_by = ['block_date'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['block_date', 'blockchain', 'project', 'version', 'tx_hash', 'evt_index', 'trace_address'],
    post_hook='{{ expose_spells(\'["ethereum"]\',
                                "project",
                                "pancakeswap_v2",
                                \'["chef_seaweed"]\') }}'
    )
}}

{% set project_start_date = '2022-08-03' %}

WITH dexs AS
(
    -- PancakeSwap v2 on ethereum
    SELECT
        t.evt_block_time                                                                AS block_time,
        t.to                                                                            AS taker,
        ''                                                                              AS maker,
        CASE WHEN amount0Out = '0' THEN amount1Out ELSE amount0Out END                  AS token_bought_amount_raw,
        CASE WHEN amount0In = '0' OR amount1Out = '0' THEN amount1In ELSE amount0In END AS token_sold_amount_raw,
        cast(NULL as double)                                                            AS amount_usd,
        CASE WHEN amount0Out = '0' THEN f.token1 ELSE f.token0 END                      AS token_bought_address,
        CASE WHEN amount0In = '0' OR amount1Out = '0' THEN f.token1 ELSE f.token0 END   AS token_sold_address,
        t.contract_address                                                              AS project_contract_address,
        t.evt_tx_hash                                                                   AS tx_hash,
        ''                                                                              AS trace_address,
        t.evt_index
    FROM
        {{ source('pancakeswap_v2_ethereum', 'PancakePair_evt_Swap') }} t
    INNER JOIN
        {{ source('pancakeswap_v2_ethereum', 'PancakeFactory_evt_PairCreated') }} f
        ON t.contract_address = f.pair
    {% if is_incremental() %}
    WHERE t.evt_block_time >= date_add('week', -1, CURRENT_TIMESTAMP(6))
    {% endif %}
)

SELECT
    'ethereum'                                                   AS blockchain
     , 'pancakeswap'                                             AS project
     , '2'                                                       AS version
     , TRY_CAST(date_trunc('DAY', dexs.block_time) AS date)      AS block_date
     , dexs.block_time
     , erc20a.symbol                                             AS token_bought_symbol
     , erc20b.symbol                                             AS token_sold_symbol
     , case
           when lower(erc20a.symbol) > lower(erc20b.symbol) then concat(erc20b.symbol, '-', erc20a.symbol)
           else concat(erc20a.symbol, '-', erc20b.symbol)
       end                                                       AS token_pair
     , dexs.token_bought_amount_raw / power(10, erc20a.decimals) AS token_bought_amount
     , dexs.token_sold_amount_raw / power(10, erc20b.decimals)   AS token_sold_amount
     , CAST(dexs.token_bought_amount_raw AS DECIMAL(38,0)) AS token_bought_amount_raw
     , CAST(dexs.token_sold_amount_raw AS DECIMAL(38,0)) AS token_sold_amount_raw
     , coalesce(
        dexs.amount_usd
        , (dexs.token_bought_amount_raw / power(10, p_bought.decimals)) * p_bought.price
        , (dexs.token_sold_amount_raw / power(10, p_sold.decimals)) * p_sold.price
        )                                                        AS amount_usd
     , dexs.token_bought_address
     , dexs.token_sold_address
     , coalesce(dexs.taker, tx."from")                             AS taker -- subqueries rely on this COALESCE to avoid redundant joins with the transactions table
     , dexs.maker
     , dexs.project_contract_address
     , dexs.tx_hash
     , tx."from"                                                   AS tx_from
     , tx.to                                                     AS tx_to
     , dexs.trace_address
     , dexs.evt_index
FROM dexs
INNER JOIN {{ source('ethereum', 'transactions') }} tx
    ON tx.hash = dexs.tx_hash
    {% if not is_incremental() %}
    AND tx.block_time >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND tx.block_time >= date_add('week', -1, CURRENT_TIMESTAMP(6))
    {% endif %}
LEFT JOIN {{ ref('tokens_erc20') }} erc20a
    ON erc20a.contract_address = dexs.token_bought_address
    AND erc20a.blockchain = 'ethereum'
LEFT JOIN {{ ref('tokens_erc20') }} erc20b
    ON erc20b.contract_address = dexs.token_sold_address
    AND erc20b.blockchain = 'ethereum'
LEFT JOIN {{ source('prices', 'usd') }} p_bought
    ON p_bought.minute = date_trunc('minute', dexs.block_time)
    AND p_bought.contract_address = dexs.token_bought_address
    AND p_bought.blockchain = 'ethereum'
    {% if not is_incremental() %}
    AND p_bought.minute >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p_bought.minute >= date_add('week', -1, CURRENT_TIMESTAMP(6))
    {% endif %}
LEFT JOIN {{ source('prices', 'usd') }} p_sold
    ON p_sold.minute = date_trunc('minute', dexs.block_time)
    AND p_sold.contract_address = dexs.token_sold_address
    AND p_sold.blockchain = 'ethereum'
    {% if not is_incremental() %}
    AND p_sold.minute >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p_sold.minute >= date_add('week', -1, CURRENT_TIMESTAMP(6))
    {% endif %}
;
