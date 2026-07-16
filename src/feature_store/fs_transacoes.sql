-- Quantidade de transações por produto D28;                    --
-- Quantidade de transações: D7, D28, D56, Vida;                -- Done
-- Total transações / quantidade de dias (que o usuário esteve ativo): D7, D28, D56, Vida;   --

WITH tb_transacao AS (
    SELECT t1.IdCliente,
            t1.IdTransacao,
            t1.DtCriacao - INTERVAL 3 HOUR AS dtTransacao
    FROM silver.upsell.transacoes AS t1
    WHERE t1.DtCriacao - INTERVAL 3 HOUR < '{dt_ref}'
),

tb_ds AS (
    SELECT t1.IdCliente,
            count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 7 DAY THEN t1.IdTransacao END) AS nrQtdeTransacaoD7, 
            count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 28 DAY THEN t1.IdTransacao END) AS nrQtdeTransacaoD28, 
            count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 56 DAY THEN t1.IdTransacao END) AS nrQtdeTransacaoD56, 
            count(DISTINCT t1.IdTransacao) AS nrQtdeTransacaoVida, 
            round(try_divide(count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 7 DAY THEN t1.IdTransacao END), count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 7 DAY THEN DATE(t1.dtTransacao) END)), 4) AS nrQtdeTransacaoDiaD7, 
            round(try_divide(count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 28 DAY THEN t1.IdTransacao END), count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 28 DAY THEN DATE(t1.dtTransacao) END)), 4) AS nrQtdeTransacaoDiaD28, 
            round(try_divide(count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 56 DAY THEN t1.IdTransacao END), count(DISTINCT CASE WHEN t1.dtTransacao > '{dt_ref}' - INTERVAL 56 DAY THEN DATE(t1.dtTransacao) END)), 4) AS nrQtdeTransacaoDiaD56, 
            round(try_divide(count(DISTINCT t1.IdTransacao), count(DISTINCT DATE(t1.dtTransacao))), 4) AS nrQtdeTransacaoDiaVida

    FROM tb_transacao AS t1
    GROUP BY IdCliente
),

tb_produtos AS (
    -- Deixar os dados dessa forma pode deixar o modelo meio bobo, é melhor normalizar os dados
    -- Comparar o perfil de compra das pessoas
    SELECT t1.IdCliente,
        round(count(CASE WHEN t3.descNomeProduto = 'espada' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctEspada,
        round(count(CASE WHEN t3.descNomeProduto = 'armadura' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctArmadura,
        round(count(CASE WHEN t3.descNomeProduto = 'botas' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctBotas,
        round(count(CASE WHEN t3.descNomeProduto = 'cajado' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctCajado,
        round(count(CASE WHEN t3.descNomeProduto = 'chapeu' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctChapeu,
        round(count(CASE WHEN t3.descNomeProduto = 'adaga' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctAdaga,
        round(count(CASE WHEN t3.descNomeProduto = 'lovers' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctLovers,
        round(count(CASE WHEN t3.descNomeProduto = 'rpg' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctRpg,
        round(count(CASE WHEN t3.descNomeProduto = 'present' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctPresent,
        round(count(CASE WHEN t3.descNomeProduto = 'streamelements' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctStreamelements,
        round(count(CASE WHEN t3.descNomeProduto = 'ponei' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctPonei,
        round(count(CASE WHEN t3.descNomeProduto = 'food' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctFood,
        round(count(CASE WHEN t3.descNomeProduto = 'chat' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctChat,
        round(count(CASE WHEN t3.descNomeProduto = 'churn_model' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctChurnModel,
        round(count(CASE WHEN t3.descNomeProduto = 'fiel' THEN t3.descNomeProduto END) / count(DISTINCT t1.IdTransacao), 4) AS nrPctFiel

    FROM tb_transacao AS t1

    LEFT JOIN silver.upsell.transacao_produto AS t2
    ON t1.IdTransacao = t2.IdTransacao
    LEFT JOIN silver.upsell.produtos AS t3
    ON t2.IdProduto = t3.IdProduto

    WHERE t1.dtTransacao >= '{dt_ref}' - INTERVAL 28 DAY

    GROUP BY t1.idcliente
)

SELECT '{dt_ref}' AS dtRef,
        t1.*,
        t2.nrQtdeTransacaoD7,
        t2.nrQtdeTransacaoD28,
        t2.nrQtdeTransacaoD56,
        t2.nrQtdeTransacaoVida,
        t2.nrQtdeTransacaoDiaD7,
        t2.nrQtdeTransacaoDiaD28,
        t2.nrQtdeTransacaoDiaD56,
        t2.nrQtdeTransacaoDiaVida
FROM tb_produtos AS t1
LEFT JOIN tb_ds AS t2
ON t1.IdCliente = t2.IdCliente

