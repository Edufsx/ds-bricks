WITH tb_ativa AS (
    SELECT *
    FROM silver.upsell.transacoes

    WHERE DtCriacao - INTERVAL 3 HOUR < '{dt_ref}'
    AND DtCriacao - INTERVAL 3 HOUR >= '{dt_ref}' - INTERVAL 28 DAY
),
    tb_recencia AS (
        SELECT IdCliente,
               min(date_diff('{dt_ref}', DtCriacao - INTERVAL 3 HOUR)) AS nrRecencia
        FROM tb_ativa

        GROUP BY IdCliente
    ),
    tb_vida AS (
        SELECT IdCliente,
               sum(QtdePontos) AS nrSaldoPts,
               max(date_diff('{dt_ref}', DtCriacao - INTERVAL 3 HOUR)) AS idadeBase
        FROM silver.upsell.transacoes

        WHERE DtCriacao - INTERVAL 3 HOUR < '{dt_ref}'
        AND idCliente in (SELECT IdCliente FROM tb_recencia)
        
        GROUP BY IdCliente
        ORDER BY idadeBase 
    ),
    tb_join AS (
        SELECT t1.*, 
               t2.nrSaldoPts,
               t2.idadeBase,
               t3.flEmail
        FROM tb_recencia AS t1
        LEFT JOIN tb_vida AS t2
        ON t1.idcliente = t2.idcliente
        LEFT JOIN silver.upsell.clientes AS t3
        ON t1.idcliente = t3.idCliente
    )
    SELECT '{dt_ref}' as dtRef,
           * 
    FROM tb_join