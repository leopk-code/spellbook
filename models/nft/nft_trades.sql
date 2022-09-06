{{ config(
    alias = 'trades',
    partition_by = ['block_time'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['block_time', 'unique_trade_id']
    )
}}

SELECT *
FROM
(
        SELECT
                blockchain,
                project,
                version,
                block_time,
                token_id,
                collection,
                amount_usd,
                token_standard,
                trade_type,
                number_of_items,
                trade_category,
                evt_type,
                seller,
                buyer,
                amount_original,
                amount_raw,
                currency_symbol,
                currency_contract,
                nft_contract_address,
                project_contract_address,
                aggregator_name,
                aggregator_address,
                tx_hash,
                block_number,
                tx_from,
                tx_to,
                unique_trade_id
        FROM {{ ref('opensea_trades') }}
        {% if is_incremental() %}
        WHERE block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
        UNION
        SELECT
                blockchain,
                project,
                version,
                block_time,
                token_id,
                collection,
                amount_usd,
                token_standard,
                trade_type,
                number_of_items,
                trade_category,
                evt_type,
                seller,
                buyer,
                amount_original,
                amount_raw,
                currency_symbol,
                currency_contract,
                nft_contract_address,
                project_contract_address,
                aggregator_name,
                aggregator_address,
                tx_hash,
                block_number,
                tx_from,
                tx_to,
                unique_trade_id
        FROM {{ ref('magiceden_trades') }}
        {% if is_incremental() %}
        WHERE block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
        UNION
        SELECT
                blockchain,
                project,
                version,
                block_time,
                token_id,
                collection,
                amount_usd,
                token_standard,
                trade_type,
                number_of_items,
                trade_category,
                evt_type,
                seller,
                buyer,
                amount_original,
                amount_raw,
                currency_symbol,
                currency_contract,
                nft_contract_address,
                project_contract_address,
                aggregator_name,
                aggregator_address,
                tx_hash,
                block_number,
                tx_from,
                tx_to,
                unique_trade_id
        FROM {{ ref('looksrare_ethereum_trades') }}
        {% if is_incremental() %}
        WHERE block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
        UNION
        SELECT
                blockchain,
                project,
                version,
                block_time,
                token_id,
                collection,
                amount_usd,
                token_standard,
                trade_type,
                number_of_items,
                trade_category,
                evt_type,
                seller,
                buyer,
                amount_original,
                amount_raw,
                currency_symbol,
                currency_contract,
                nft_contract_address,
                project_contract_address,
                aggregator_name,
                aggregator_address,
                tx_hash,
                block_number,
                tx_from,
                tx_to,
                unique_trade_id
        FROM {{ ref('x2y2_ethereum_trades') }}
        {% if is_incremental() %}
        WHERE block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
        UNION
        SELECT
                blockchain,
                project,
                version,
                block_time,
                token_id,
                collection,
                amount_usd,
                token_standard,
                trade_type,
                number_of_items,
                trade_category,
                evt_type,
                seller,
                buyer,
                amount_original,
                amount_raw,
                currency_symbol,
                currency_contract,
                nft_contract_address,
                project_contract_address,
                aggregator_name,
                aggregator_address,
                tx_hash,
                block_number,
                tx_from,
                tx_to,
                unique_trade_id
        FROM {{ ref('sudoswap_ethereum_trades') }}
        {% if is_incremental() %}
        WHERE block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
        UNION
        SELECT
                blockchain,
                project,
                version,
                block_time,
                token_id,
                collection,
                amount_usd,
                token_standard,
                trade_type,
                number_of_items,
                trade_category,
                evt_type,
                seller,
                buyer,
                amount_original,
                amount_raw,
                currency_symbol,
                currency_contract,
                nft_contract_address,
                project_contract_address,
                aggregator_name,
                aggregator_address,
                tx_hash,
                block_number,
                tx_from,
                tx_to,
                unique_trade_id
        FROM {{ ref('archipelago_ethereum_trades') }}
        {% if is_incremental() %}
        WHERE block_time >= date_trunc("day", now() - interval '1 week')
        {% endif %}
)
