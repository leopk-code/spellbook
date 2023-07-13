{{config(alias = alias('labels_balancer_v1_pools', legacy_model=True),
        post_hook='{{ expose_spells(\'["ethereum"]\',
                                    "sector",
                                    "labels",
                                    \'["balancerlabs"]\') }}')}}

SELECT * FROM  {{ ref('labels_balancer_v1_pools_ethereum_legacy') }}