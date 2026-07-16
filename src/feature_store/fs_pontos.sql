-- Quantidade de pontos acumulados: D7, D28, D56; Vida;  --DONE


-- Quantidade de pontos por produto (absoluto);          --DONE

-- Média de pontos por dia: D28;                         --DONE          
-- Pontos / Transação;

WITH tb_transacao AS (
    SELECT t1.*,
            t1.DtCriacao - INTERVAL 3 HOUR AS dtTransacao
    FROM silver.upsell.transacoes AS t1
    WHERE t1.DtCriacao - INTERVAL 3 HOUR < '{dt_ref}'
),
tb_ds AS (
    SELECT IdCliente,
            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 7 DAY THEN QtdePontos END) AS nrSaldoPontosD7,
            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 28 DAY THEN QtdePontos END) AS nrSaldoPontosD28, 
            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 56 DAY THEN QtdePontos END) AS nrSaldoPontosD56,
            sum(QtdePontos) AS nrSaldoPontosVida,

            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 7 DAY AND QtdePontos > 0 THEN QtdePontos END) AS nrPontosPosD7,
            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 28 DAY AND QtdePontos > 0 THEN QtdePontos END) AS nrPontosPosD28, 
            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 56 DAY AND QtdePontos > 0 THEN QtdePontos END) AS nrPontosPosD56,
            sum(CASE WHEN QtdePontos > 0 THEN QtdePontos END) AS nrPontosPosVida,

            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 7 DAY AND QtdePontos < 0 THEN ABS(QtdePontos) END) AS nrPontosNegD7,
            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 28 DAY AND QtdePontos < 0 THEN ABS(QtdePontos) END) AS nrPontosNegD28, 
            sum(CASE WHEN dtTransacao >= '{dt_ref}' - INTERVAL 56 DAY AND QtdePontos < 0 THEN ABS(QtdePontos) END) AS nrPontosNegD56,
            sum(CASE WHEN QtdePontos < 0 THEN ABS(QtdePontos) END) AS nrPontosNegVida

    FROM tb_transacao
    
    GROUP BY IdCliente
),
tb_produtos AS (
        SELECT t1.IdCliente,
                sum(CASE WHEN t3.descCategoriaProduto = 'espada' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosEspada,
                sum(CASE WHEN t3.descCategoriaProduto = 'armadura' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosArmadura,
                sum(CASE WHEN t3.descCategoriaProduto = 'botas' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosBotas,
                sum(CASE WHEN t3.descCategoriaProduto = 'cajado' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosCajado,
                sum(CASE WHEN t3.descCategoriaProduto = 'chapeu' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosChapeu,
                sum(CASE WHEN t3.descCategoriaProduto = 'adaga' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosAdaga,
                sum(CASE WHEN t3.descCategoriaProduto = 'lovers' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosLovers,
                sum(CASE WHEN t3.descCategoriaProduto = 'rpg' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosRpg,
                sum(CASE WHEN t3.descCategoriaProduto = 'present' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosPresent,
                sum(CASE WHEN t3.descCategoriaProduto = 'streamelements' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosStreamelements,
                sum(CASE WHEN t3.descCategoriaProduto = 'ponei' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosPonei,
                sum(CASE WHEN t3.descCategoriaProduto = 'food' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosFood,
                sum(CASE WHEN t3.descCategoriaProduto = 'chat' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosChat,
                sum(CASE WHEN t3.descCategoriaProduto = 'churn_model' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosChurnModel,
                sum(CASE WHEN t3.descCategoriaProduto = 'fiel' THEN ABS(t1.QtdePontos) END) / sum(ABS(t1.QtdePontos)) AS nrPctPontosFiel,
            
                round(sum(t1.QtdePontos) / count(DISTINCT DATE(t1.dtTransacao)), 4) AS nrMediaPontosDia,
                round(sum(ABS(t1.QtdePontos)) / count(DISTINCT DATE(t1.dtTransacao)), 4) AS nrMediaPontosGeralDia,
                round(sum(CASE WHEN t1.QtdePontos > 0 THEN t1.QtdePontos END) / count(DISTINCT CASE WHEN t1.QtdePontos > 0 THEN DATE(t1.dtTransacao) END), 4) AS nrMediaPontosPosDia,
                round(sum(CASE WHEN t1.QtdePontos < 0 THEN ABS(t1.QtdePontos) END) / count(DISTINCT CASE WHEN t1.QtdePontos < 0 THEN DATE(t1.dtTransacao) END), 4) AS nrMediaPontosNegDia,

                round(sum(ABS(t1.QtdePontos)) / count(DISTINCT t1.IdTransacao), 4) AS qtdePontosGeralTransacao,
                round(sum(t1.QtdePontos) / count(DISTINCT t1.IdTransacao), 4) AS qtdePontosTransacao,
                round(sum(CASE WHEN t1.QtdePontos > 0 THEN t1.QtdePontos END) / count(DISTINCT CASE WHEN t1.QtdePontos > 0 THEN t1.IdTransacao END), 4) AS qtdePontosPosTransacao,
                round(sum(CASE WHEN t1.QtdePontos < 0 THEN abs(t1.QtdePontos) END) / count(DISTINCT CASE WHEN t1.QtdePontos < 0 THEN t1.IdTransacao END), 4) AS qtdePontosNegTransacao
                
        FROM tb_transacao AS t1

        LEFT JOIN silver.upsell.transacao_produto AS t2
        ON t1.IdTransacao = t2.IdTransacao
        LEFT JOIN silver.upsell.produtos AS t3
        ON t2.IdProduto = t3.IdProduto 

        WHERE t1.dtTransacao >= '{dt_ref}' - INTERVAL 28 DAY

        GROUP BY t1.IdCliente
)

SELECT '{dt_ref}' AS dtRef,
        t1.*,
        t2.nrSaldoPontosD7,
        t2.nrSaldoPontosD28,
        t2.nrSaldoPontosD56,
        t2.nrSaldoPontosVida,
        t2.nrPontosPosD7,
        t2.nrPontosPosD28,
        t2.nrPontosPosD56,
        t2.nrPontosPosVida,
        t2.nrPontosNegD7,
        t2.nrPontosNegD28,
        t2.nrPontosNegD56,
        t2.nrPontosNegVida
FROM tb_produtos AS t1
LEFT JOIN tb_ds AS t2
ON t1.IdCliente = t2.IdCliente
