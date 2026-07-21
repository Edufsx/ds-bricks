WITH tb_daily AS (
    SELECT DISTINCT
            IdCliente,
            date(DtCriacao) AS dtDia
    FROM silver.upsell.transacoes
    ORDER BY IdCliente, dtDia
),

tb_ref AS (
    SELECT dtRef,
            IdCliente
    FROM feature_store.upsell.fs_geral
    WHERE day(dtRef) = 1
),
tb_churn AS (
        SELECT t1.dtRef,
                t1.IdCliente,
                max(CASE WHEN t2.IdCliente IS NULL THEN 1 ELSE 0 END) AS flChurn
        FROM tb_ref AS t1

        LEFT JOIN tb_daily AS t2
        ON t1.IdCliente = t2.IdCliente
        AND t1.dtRef <= t2.dtDia
        AND t1.dtRef >  t2.dtDia - INTERVAL 28 day


        GROUP BY ALL
        ORDER BY t1.idcliente, t1.dtRef
)

SELECT *
FROM tb_churn
-- Escolhendo dois pontos dos usuários de forma aleatória
-- IID (uma linha do seu dataset deveria ser independente da outro, mas sem perder volume)
QUALIFY row_number() OVER (PARTITION BY IdCliente ORDER BY rand()) <= 2
