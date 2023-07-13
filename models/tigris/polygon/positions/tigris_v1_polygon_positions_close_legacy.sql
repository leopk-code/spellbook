{{ config(
    schema = 'tigris_v1_polygon',
    alias = alias('positions_close', legacy_model=True)
    )
 }}

WITH 

latest_leverage as (
    SELECT 
        ab.*, 
        l.leverage 
    FROM 
    (
    SELECT 
        MAX(l.evt_block_time) as latest_leverage_time, 
        cp.evt_block_time, 
        cp.evt_tx_hash,
        cp.position_id,
        cp.payout, 
        cp.evt_index,
        cp.version,
        cp.price, 
        cp.trader, 
        (100/cp.perc_closed) * cp.payout as previous_margin, 
        ((100/cp.perc_closed) * cp.payout) - cp.payout as new_margin
    FROM 
    {{ ref('tigris_v1_polygon_events_close_position_legacy') }} cp 
    INNER JOIN 
    {{ ref('tigris_v1_polygon_positions_leverage_legacy') }} l 
        ON cp.position_id = l.position_id 
        AND cp.version = l.version -- commenting this out to test 
        AND cp.evt_block_time > l.evt_block_time
    GROUP BY 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ) ab 
    INNER JOIN 
    {{ ref('tigris_v1_polygon_positions_leverage_legacy') }} l 
        ON ab.position_id = l.position_id
        AND ab.latest_leverage_time = l.evt_block_time
        AND ab.version = l.version 
)

SELECT * FROM latest_leverage
;