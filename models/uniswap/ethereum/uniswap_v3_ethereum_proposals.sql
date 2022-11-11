{{ config(
    schema = 'uniswap_v3_ethereum',
    alias = 'proposals',
    partition_by = ['block_date'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['block_time', 'blockchain', 'project', 'version', 'tx_hash'],
    post_hook='{{ expose_spells(\'["ethereum"]\',
                                "project",
                                "uniswap_v3",
                                \'["soispoke"]\') }}'
    )
}}

{% set blockchain = 'ethereum' %}
{% set project = 'uniswap' %}
{% set project_version = 'v3' %}
{% set dao_name = 'DAO: Uniswap' %}
{% set dao_address = '0x408ed6354d4973f66138c91495f2f2fcbd8724c3' %}

with cte_support as (SELECT 
        voter as voter,
        CASE WHEN support = 0 THEN sum(votes/1e18) ELSE 0 END AS votes_against,
        CASE WHEN support = 1 THEN sum(votes/1e18) ELSE 0 END AS votes_for,
        CASE WHEN support = 2 THEN sum(votes/1e18) ELSE 0 END AS votes_abstain,
        proposalId
FROM {{ source('uniswap_v3_ethereum', 'GovernorBravoDelegate_evt_VoteCast') }}
GROUP BY support, proposalId, voter),

cte_sum_votes as (
SELECT COUNT(DISTINCT voter) as number_of_voters,
       SUM(votes_for) as votes_for, 
       SUM(votes_against) as votes_against, 
       SUM(votes_abstain) as votes_abstain, 
       SUM(votes_for) + SUM(votes_against) + SUM(votes_abstain) as votes_total,
       proposalId
from cte_support
GROUP BY proposalId)

SELECT 
    '{{blockchain}}' as blockchain,
    '{{project}}' as project,
    '{{project_version}}' as version,
    pcr.evt_block_time as block_time,
    date_trunc('DAY', pcr.evt_block_time) AS block_date,
    pcr.evt_tx_hash as tx_hash, -- Proposal Created tx hash
    '{{dao_name}}' as dao_name,
    '{{dao_address}}' as dao_address,
    proposer as proposer,
    pcr.id as proposal_id,
    votes_for as votes_for,
    votes_against as votes_against,
    votes_abstain as votes_abstain,
    votes_total as votes_total,
    number_of_voters as number_of_voters,
    votes_total / 1e9 * 100 AS participation, -- Total votes / Total supply (1B for Uniswap)
    startBlock as start_block,
    endBlock as end_block,
    CASE WHEN now() > pqu.evt_block_time AND startBlock > pcr.evt_block_number THEN 'Queued'
         WHEN startBlock < pcr.evt_block_number < endBlock THEN 'Active'
         WHEN pex.id is not null and now() > pex.evt_block_time THEN 'Executed' 
         WHEN pca.id is not null and now() > pca.evt_block_time THEN 'Canceled'
         ELSE 'Defeated' END AS status,
    description as description
FROM  {{ source('uniswap_v3_ethereum', 'GovernorBravoDelegate_evt_ProposalCreated') }} pcr
LEFT JOIN cte_sum_votes csv ON csv.proposalId = pcr.id
LEFT JOIN {{ source('uniswap_v3_ethereum', 'GovernorBravoDelegate_evt_ProposalCanceled') }} pca ON pca.id = pcr.id
LEFT JOIN {{ source('uniswap_v3_ethereum', 'GovernorBravoDelegate_evt_ProposalExecuted') }} pex ON pex.id = pcr.id
LEFT JOIN {{ source('uniswap_v3_ethereum', 'GovernorBravoDelegate_evt_ProposalQueued') }} pqu ON pex.id = pcr.id
{% if is_incremental() %}
WHERE pcr.evt_block_time >= date_trunc("day", now() - interval '1 week')
{% endif %}