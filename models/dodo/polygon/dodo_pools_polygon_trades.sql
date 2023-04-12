{{ config
(
    alias ='pool_trades',
    partition_by = ['block_date'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['block_date', 'blockchain', 'project', 'version', 'tx_hash', 'evt_index', 'trace_address'],
    post_hook='{{ expose_spells(\'["polygon"]\',
                                    "project",
                                    "dodo",
                                    \'["owen05"]\') }}'
)
}}
    
{% set project_start_date = '2021-05-17' %}

-- dodo V1 & V2 adapters
{% set dodo_proxies = [
"0xdbfaf391c37339c903503495395ad7d6b096e192",
"0x6c30be15d88462b788dea7c6a860a2ccaf7b2670"
] %}

WITH dodo_view_markets (market_contract_address, base_token_symbol, quote_token_symbol, base_token_address, quote_token_address) AS 
(
    VALUES
    (lower(0x813fddeccd0401c4fa73b092b074802440544e52), 'USDC', 'USDT', lower(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174), lower(0xc2132D05D31c914a87C6611C10748AEb04B58e8F))
)
, dexs AS 
(
        -- dodo v1 sell
        SELECT
            s.evt_block_time AS block_time,
            'DODO' AS project,
            '1' AS version,
            s.seller AS taker,
            '' AS maker,
            s.payBase AS token_bought_amount_raw,
            s.receiveQuote AS token_sold_amount_raw,
            cast(NULL as double) AS amount_usd,
            m.base_token_address AS token_bought_address,
            m.quote_token_address AS token_sold_address,
            s.contract_address AS project_contract_address,
            s.evt_tx_hash AS tx_hash,
            '' AS trace_address,
            s.evt_index
        FROM
            {{ source('dodoex_polygon', 'DODO_evt_SellBaseToken')}} s
        LEFT JOIN dodo_view_markets m
            on s.contract_address = m.market_contract_address
        WHERE
        {% for dodo_proxy in dodo_proxies %}
            s.seller <> '{{dodo_proxy}}'
            {% if not loop.last %}
            and
            {% endif %}
        {% endfor %}
        {% if is_incremental() %}
        AND s.evt_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
    
         UNION ALL

        -- dodo v1 buy
        SELECT
            b.evt_block_time AS block_time,
            'DODO' AS project,
            '1' AS version,
            b.buyer AS taker,
            '' AS maker,
            b.receiveBase AS token_bought_amount_raw,
            b.payQuote AS token_sold_amount_raw,
            cast(NULL as double) AS amount_usd,
            m.base_token_address AS token_bought_address,
            m.quote_token_address AS token_sold_address,
            b.contract_address AS project_contract_address,
            b.evt_tx_hash AS tx_hash,
            '' AS trace_address,
            b.evt_index
        FROM
            {{ source('dodoex_polygon','DODO_evt_BuyBaseToken')}} b
        LEFT JOIN dodo_view_markets m
            on b.contract_address = m.market_contract_address
        WHERE
        {% for dodo_proxy in dodo_proxies %}
            b.buyer <> '{{dodo_proxy}}'
            {% if not loop.last %}
            and
            {% endif %}
        {% endfor %}
        {% if is_incremental() %}
        AND b.evt_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}

        UNION ALL

        -- dodov2 dvm
        SELECT
            evt_block_time AS block_time,
            'DODO' AS project,
            '2_dvm' AS version,
            trader AS taker,
            receiver AS maker,
            fromAmount AS token_bought_amount_raw,
            toAmount AS token_sold_amount_raw,
            cast(NULL as double) AS amount_usd,
            fromToken AS token_bought_address,
            toToken AS token_sold_address,
            contract_address AS project_contract_address,
            evt_tx_hash AS tx_hash,
            '' AS trace_address,
            evt_index
        FROM
            {{ source('dodoex_polygon', 'DVM_evt_DODOSwap')}}
        WHERE
        {% for dodo_proxy in dodo_proxies %}
            trader <> '{{dodo_proxy}}'
            {% if not loop.last %}
            and
            {% endif %}
        {% endfor %}
        {% if is_incremental() %}
        AND evt_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}

        UNION ALL

        -- dodov2 dpp
        SELECT
            evt_block_time AS block_time,
            'DODO' AS project,
            '2_dpp' AS version,
            trader AS taker,
            receiver AS maker,
            fromAmount AS token_bought_amount_raw,
            toAmount AS token_sold_amount_raw,
            cast(NULL as double)  AS amount_usd,
            fromToken AS token_bought_address,
            toToken AS token_sold_address,
            contract_address AS project_contract_address,
            evt_tx_hash AS tx_hash,
            '' AS trace_address,
            evt_index
        FROM
            {{ source('dodoex_polygon', 'DPP_evt_DODOSwap')}}
        WHERE
        {% for dodo_proxy in dodo_proxies %}
            trader <> '{{dodo_proxy}}'
            {% if not loop.last %}
            and
            {% endif %}
        {% endfor %}
        {% if is_incremental() %}
        AND evt_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}

        UNION ALL

        -- dodov2 dppAdvanced
        SELECT
            evt_block_time AS block_time,
            'DODO' AS project,
            '2_dpp' AS version,
            trader AS taker,
            receiver AS maker,
            fromAmount AS token_bought_amount_raw,
            toAmount AS token_sold_amount_raw,
            cast(NULL as double)  AS amount_usd,
            fromToken AS token_bought_address,
            toToken AS token_sold_address,
            contract_address AS project_contract_address,
            evt_tx_hash AS tx_hash,
            '' AS trace_address,
            evt_index
        FROM
            {{ source('dodoex_polygon', 'DPPAdvanced_evt_DODOSwap')}}
        WHERE
        {% for dodo_proxy in dodo_proxies %}
            trader <> '{{dodo_proxy}}'
            {% if not loop.last %}
            and
            {% endif %}
        {% endfor %}
        {% if is_incremental() %}
        AND evt_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}

        UNION ALL

        -- dodov2 dppOracle
        SELECT
            evt_block_time AS block_time,
            'DODO' AS project,
            '2_dpp' AS version,
            trader AS taker,
            receiver AS maker,
            fromAmount AS token_bought_amount_raw,
            toAmount AS token_sold_amount_raw,
            cast(NULL as double)  AS amount_usd,
            fromToken AS token_bought_address,
            toToken AS token_sold_address,
            contract_address AS project_contract_address,
            evt_tx_hash AS tx_hash,
            '' AS trace_address,
            evt_index
        FROM
            {{ source('dodoex_polygon', 'DPPOracle_evt_DODOSwap')}}
        WHERE
        {% for dodo_proxy in dodo_proxies %}
            trader <> '{{dodo_proxy}}'
            {% if not loop.last %}
            and
            {% endif %}
        {% endfor %}
        {% if is_incremental() %}
        AND evt_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}

        UNION ALL


        -- dodov2 dsp
        SELECT
            evt_block_time AS block_time,
            'DODO' AS project,
            '2_dsp' AS version,
            trader AS taker,
            receiver AS maker,
            fromAmount AS token_bought_amount_raw,
            toAmount AS token_sold_amount_raw,
            cast(NULL as double) AS amount_usd,
            fromToken AS token_bought_address,
            toToken AS token_sold_address,
            contract_address AS project_contract_address,
            evt_tx_hash AS tx_hash,
            '' AS trace_address,
            evt_index
        FROM
            {{ source('dodoex_polygon', 'DSP_evt_DODOSwap')}}
        WHERE
        {% for dodo_proxy in dodo_proxies %}
            trader <> '{{dodo_proxy}}'
            {% if not loop.last %}
            and
            {% endif %}
        {% endfor %}
        {% if is_incremental() %}
        AND evt_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
)
SELECT
    'polygon' AS blockchain
    ,project
    ,dexs.version as version
    ,TRY_CAST(date_trunc('DAY', dexs.block_time) AS date) AS block_date
    ,dexs.block_time
    ,erc20a.symbol AS token_bought_symbol
    ,erc20b.symbol AS token_sold_symbol
    ,case
        when lower(erc20a.symbol) > lower(erc20b.symbol) then concat(erc20b.symbol, '-', erc20a.symbol)
        else concat(erc20a.symbol, '-', erc20b.symbol)
    end as token_pair
    ,dexs.token_bought_amount_raw / power(10, erc20a.decimals) AS token_bought_amount
    ,dexs.token_sold_amount_raw / power(10, erc20b.decimals) AS token_sold_amount
    ,CAST(dexs.token_bought_amount_raw AS DECIMAL(38,0)) AS token_bought_amount_raw
    ,CAST(dexs.token_sold_amount_raw AS DECIMAL(38,0)) AS token_sold_amount_raw
    ,coalesce(
        dexs.amount_usd
        ,(dexs.token_bought_amount_raw / power(10, (CASE dexs.token_bought_address WHEN 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee THEN 18 ELSE p_bought.decimals END))) * (CASE dexs.token_bought_address WHEN 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee THEN  p_eth.price ELSE p_bought.price END)
        ,(dexs.token_sold_amount_raw / power(10, (CASE dexs.token_sold_address WHEN 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee THEN 18 ELSE p_sold.decimals END))) * (CASE dexs.token_sold_address WHEN 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee THEN  p_eth.price ELSE p_sold.price END)
    ) as amount_usd
    ,dexs.token_bought_address
    ,dexs.token_sold_address
    ,coalesce(dexs.taker, tx.from) AS taker -- subqueries rely on this COALESCE to avoid redundant joins with the transactions table
    ,dexs.maker
    ,dexs.project_contract_address
    ,dexs.tx_hash
    ,tx.from AS tx_from
    ,tx.to AS tx_to
    ,dexs.trace_address
    ,dexs.evt_index
FROM dexs
INNER JOIN {{ source('polygon', 'transactions')}} tx
    ON dexs.tx_hash = tx.hash
    {% if not is_incremental() %}
    AND tx.block_time >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND tx.block_time >= date_trunc("day", now() - interval '1 week')
    {% endif %}
LEFT JOIN {{ ref('tokens_erc20') }} erc20a
    ON erc20a.contract_address = dexs.token_bought_address
    AND erc20a.blockchain = 'polygon'
LEFT JOIN {{ ref('tokens_erc20') }} erc20b
    ON erc20b.contract_address = dexs.token_sold_address
    AND erc20b.blockchain = 'polygon'
LEFT JOIN {{ source('prices', 'usd') }} p_bought
    ON p_bought.minute = date_trunc('minute', dexs.block_time)
    AND p_bought.contract_address = dexs.token_bought_address
    AND p_bought.blockchain = 'polygon'
    {% if not is_incremental() %}
    AND p_bought.minute >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p_bought.minute >= date_trunc("day", now() - interval '1 week')
    {% endif %}
LEFT JOIN {{ source('prices', 'usd') }} p_sold
    ON p_sold.minute = date_trunc('minute', dexs.block_time)
    AND p_sold.contract_address = dexs.token_sold_address
    AND p_sold.blockchain = 'polygon'
    {% if not is_incremental() %}
    AND p_sold.minute >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p_sold.minute >= date_trunc("day", now() - interval '1 week')
    {% endif %}
LEFT JOIN {{ source('prices', 'usd') }} p_eth
    ON p_eth.minute = date_trunc('minute', dexs.block_time)
    AND p_eth.blockchain is null
    AND p_eth.symbol = 'MATIC'
    {% if not is_incremental() %}
    AND p_eth.minute >= '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p_eth.minute >= date_trunc("day", now() - interval '1 week')
    {% endif %}
WHERE dexs.token_bought_address <> dexs.token_sold_address
;