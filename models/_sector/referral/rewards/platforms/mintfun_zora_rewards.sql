{{ config(
    schema = 'mint_fun_zora',
    alias = 'rewards',
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['project','tx_hash','sub_tx_id'],
    incremental_predicates = [incremental_predicate('DBT_INTERNAL_DEST.block_time')],
    )
}}

{{mintfun_referral_rewards(
        blockchain = "zora"
        ,MintPayout_evt_MintDeposit = source('mint_fun_zora','MintPayout_evt_MintDeposit')
        )
    }}
