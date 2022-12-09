{{ config(
        schema = 'hop_protocol',
        alias ='flows',
        post_hook='{{ expose_spells(\'["optimism"]\',
                                "project",
                                "hop_protocol",
                                \'["msilb7","soispoke"]\') }}'
        )
}}

{% set hop_flows_models = [
        'hop_protocol_optimism_flows'
] %}

SELECT *
FROM
(
        {% for hop_tf_model in hop_flows_models %}
        SELECT
                h.blockchain
                , h.project
                , h.version
                , h.block_time
                , h.block_date
                , h.block_number
                , h.tx_hash
                , h.sender
                , h.receiver
                , h.token_symbol
                , h.token_amount
                , h.token_amount_usd
                , h.token_amount_raw
                , h.token_fee_amount
                , h.token_fee_amount_usd
                , h.token_fee_amount_raw
                , h.token_address
                , h.token_fee_address
                , h.source_chain_id
                , h.destination_chain_id
                , h.source_chain_name
                , h.destination_chain_name
                , CASE WHEN sb.tx_hash IS NOT NULL
                        THEN 1 ELSE 0
                 END AS is_native_bridge
                , h.tx_from
                , h.tx_to
                , h.transfer_id
                , h.evt_index
                , h.trace_address
                , h.tx_method_id
        FROM {{ ref(hop_tf_model) }} h
        LEFT JOIN
        {% if hop_tf_model == 'hop_protocol_optimism_flows' %}
                {{ref('optimism_standard_bridge_flows')}} sb
        {% endif %}
        -- Add if statements for other chains here
        ON sb.tx_hash = h.tx_hash
        AND sb.block_number = h.block_number
        AND sb.block_date = h.block_date

    {% if not loop.last %}
    UNION ALL
    {% endif %}
    {% endfor %}
)