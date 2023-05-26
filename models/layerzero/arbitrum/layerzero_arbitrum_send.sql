{{ config(
    alias = 'send',
    partition_by = ['block_date'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['block_time', 'tx_hash', 'user_address', 'trace_address', 'source_chain_id', 'destination_chain_id', 'currency_contract']
    )
}}

{% set transaction_start_date = "2022-03-15" %}
{% set endpoint_contract = "0x66a71dcef29a0ffbdbe3c6a460a3b5bc225cd675" %}
{% set native_token_contract = "0x82af49447d8a07e3bd95bd0d56f35241523fbab1" %}

WITH send_detail AS (
    SELECT CAST(110 AS integer) AS source_chain_id,
        s.call_tx_hash as tx_hash,
        s.call_block_number as block_number,
        s._dstChainId AS destination_chain_id,
        s.contract_address,
        s.call_block_time AS block_time,
        s.call_trace_address AS trace_address,
        s._adapterParams AS adapter_params,
        s._refundAddress AS refund_address,
        s._zroPaymentAddress AS zro_payment_address,
        t.from AS user_address,
        t.to AS transaction_contract_address,
        CAST(t.value AS DOUBLE) AS transaction_value,
        CASE WHEN len(_destination) >= 82
            THEN '0x' || right(_destination, 40)
            ELSE '' END AS local_contract_address, -- 
        CASE WHEN len(_destination) >= 82
            THEN substring(_destination, 1, len(_destination) - 40)
            ELSE _destination END AS remote_contract_address
    FROM {{ source ('layerzero_arbitrum', 'Endpoint_call_send') }} s
    INNER JOIN {{ source('arbitrum','transactions') }} t on t.block_number = s.call_block_number
        AND t.hash = s.call_tx_hash
        {% if not is_incremental() %}
        AND t.block_time >= '{{transaction_start_date}}'
        {% endif %}
        {% if is_incremental() %}
        AND t.block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
    WHERE s.call_success
        {% if not is_incremental() %}
        AND s.call_block_time >= '{{transaction_start_date}}'
        {% endif %}
        {% if is_incremental() %}
        AND s.call_block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
),

send_summary AS (
    SELECT DISTINCT block_number,
        tx_hash,
        user_address,
        transaction_contract_address,
        transaction_value
    FROM send_detail
),

-- Destination gas(Endpoint send value)
destination_gas_detail AS (
    SELECT s.block_number,
        s.tx_hash,
        s.trace_address,
        CAST(e.value as double) AS destination_gas
    FROM send_detail s
    INNER JOIN {{ source('arbitrum', 'traces') }} e on e.block_number = s.block_number
        AND e.tx_hash = s.tx_hash
        AND e.trace_address = s.trace_address
        {% if not is_incremental() %}
        AND e.block_time >= '{{transaction_start_date}}'
        {% endif %}
        {% if is_incremental() %}
        AND e.block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
),

destination_trace_address_summary AS (
    SELECT block_number,
        tx_hash,
        array_agg(trace_address[0]) AS endpoint_root_trace_address
    FROM destination_gas_detail
    GROUP BY 1, 2
),

destination_gas_summary AS (
    SELECT block_number,
        tx_hash,
        sum(CAST(destination_gas as double)) AS amount_destination_gas
    FROM destination_gas_detail
    GROUP BY 1, 2
),

native_transfer_value_summary AS (
    SELECT s.block_number,
        s.tx_hash,
        dg.endpoint_root_trace_address,
        SUM(CAST(e.value as double)) AS amount_native_value
    FROM send_summary s
    INNER JOIN destination_trace_address_summary dg ON dg.block_number = s.block_number
        AND dg.tx_hash = s.tx_hash
    INNER JOIN {{ source('arbitrum', 'traces') }} e ON e.block_number = dg.block_number
        AND e.tx_hash = dg.tx_hash
        AND ARRAY_CONTAINS(dg.endpoint_root_trace_address, e.trace_address[0]) IS NOT TRUE
        AND e.from = s.transaction_contract_address
        AND e.call_type = 'call'
        AND cast(e.value as double) > 0
        AND cardinality(e.trace_address) > 0
        {% if not is_incremental() %}
        AND e.block_time >= '{{transaction_start_date}}'
        {% endif %}
        {% if is_incremental() %}
        AND e.block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
    GROUP BY 1, 2, 3
),

trans_detail AS (
    -- ERC20 transfer: Endpoint send value is equal to transaction value
    SELECT t.block_number,
        t.tx_hash,
        t.user_address,
        t.transaction_contract_address,
        t.transaction_value,
        'erc20' AS transfer_type,
        t.currency_contract,
        t.amount_raw
    FROM (
        SELECT s.*,
            et.contract_address AS currency_contract,
            CAST(et.value AS double)AS amount_raw, -- Transfer amount of the transaction
            row_number() OVER(PARTITION BY et.evt_tx_hash ORDER BY et.evt_index DESC) AS rn
        FROM send_summary s
        INNER JOIN destination_gas_summary dgs ON dgs.block_number = s.block_number
            AND dgs.tx_hash = s.tx_hash
            AND dgs.amount_destination_gas = s.transaction_value
        INNER JOIN {{ source('erc20_arbitrum', 'evt_transfer') }} et on et.evt_block_number = s.block_number
            AND et.evt_tx_hash = s.tx_hash
            {% if not is_incremental() %}
            AND et.evt_block_time >= '{{transaction_start_date}}'
            {% endif %}
            {% if is_incremental() %}
            AND et.evt_block_time >= date_trunc("day", now() - interval '1 week')
            {% endif %}
    ) t
    WHERE t.rn = 1
    
    UNION ALL

    -- Native transfer: The transaction amount != endpoint gas amount + transfer amount
    SELECT s.block_number,
        s.tx_hash,
        s.user_address,
        s.transaction_contract_address,
        s.transaction_value,
        'native' AS transfer_type,
        '{{native_token_contract}}' AS currency_contract,
        s.transaction_value - dgs.amount_destination_gas AS amount_raw -- Transfer amount of the transaction
    FROM send_summary s
    INNER JOIN destination_gas_summary dgs ON dgs.block_number = s.block_number
        AND dgs.tx_hash = s.tx_hash
        AND dgs.amount_destination_gas > 0
    INNER JOIN native_transfer_value_summary nvs ON nvs.block_number = s.block_number
        AND nvs.tx_hash = s.tx_hash
        AND nvs.amount_native_value > 0
    WHERE s.transaction_value = dgs.amount_destination_gas + nvs.amount_native_value
)

SELECT 'arbitrum' AS blockchain,
    s.source_chain_id,
    cls.chain_name AS source_chain_name,
    s.destination_chain_id,
    cld.chain_name AS destination_chain_name,
    s.tx_hash,
    s.block_number,
    s.contract_address AS endpoint_contract,
    date_trunc('day', s.block_time) AS block_date,
    s.block_time,
    s.trace_address,
    s.adapter_params,
    s.refund_address,
    s.zro_payment_address,
    s.user_address,
    s.transaction_contract_address AS transaction_contract,
    s.local_contract_address AS source_bridge_contract,
    s.remote_contract_address AS destination_bridge_contract,
    t.transfer_type,
    CASE WHEN erc.symbol = 'WETH' AND t.transfer_type = 'native'
        THEN 'ETH'
        ELSE erc.symbol END AS currency_symbol,
    t.currency_contract,
    COALESCE(t.amount_raw,0) / power(10, erc.decimals) * p.price AS amount_usd,
    COALESCE(t.amount_raw,0) / power(10, erc.decimals) AS amount_original,
    COALESCE(t.amount_raw,0) AS amount_raw
FROM send_detail s
INNER JOIN trans_detail t ON s.block_number = t.block_number
    AND s.tx_hash = t.tx_hash
LEFT JOIN {{ ref('layerzero_chain_list') }} cls ON cls.chain_id = s.source_chain_id
LEFT JOIN {{ ref('layerzero_chain_list') }} cld ON cld.chain_id = s.destination_chain_id
LEFT JOIN {{ ref('tokens_erc20') }} erc ON erc.blockchain = 'arbitrum' AND erc.contract_address = t.currency_contract
LEFT JOIN {{ source('prices', 'usd') }} p ON p.blockchain = 'arbitrum' AND p.contract_address = t.currency_contract
    AND p.minute = date_trunc('minute', s.block_time)
    {% if not is_incremental() %}
    AND p.minute >= '{{transaction_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND p.minute >= date_trunc("day", now() - interval '1 week')
    {% endif %}
