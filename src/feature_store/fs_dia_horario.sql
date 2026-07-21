
-- Quantidade de dias de iteração;                                      --DONE
-- Distribuição de horário/período de atividade do usuário;             --DONE

-- Tempo de atividade nas lives (primeira vs última iteração no dia);   --DONE
-- Tempo semanal de iteração;                                           --DONE  
-- Quantidade de lives com iteração na semana (média);                  --DONE
-- Data do MAU, dia do mês, semana do mês, mês, ano;

WITH tb_transacao AS (
    SELECT *,
            dtCriacao - INTERVAL 3 HOUR AS dtTransacao,
            HOUR(dtCriacao - INTERVAL 3 HOUR) AS dtHora
    FROM silver.upsell.transacoes

    WHERE dtCriacao < '{dt_ref}'
    AND dtCriacao >= '{dt_ref}' - INTERVAL 28 DAY
),
tb_horario AS (
        SELECT IdCliente,
                count(DISTINCT date(dtTransacao)) AS nrQtdeDiasAtivos,
                count(DISTINCT CASE WHEN dtHora BETWEEN 6 AND 12 THEN date(dtTransacao) END) AS nrQtdeDiasManha,
                count(DISTINCT CASE WHEN dtHora BETWEEN 13 AND 18 THEN date(dtTransacao) END) AS nrQtdeDiasTarde,
                count(DISTINCT CASE WHEN dtHora BETWEEN 19 AND 24 THEN date(dtTransacao) END) AS nrQtdeDiasNoite,
        
                round(count(DISTINCT CASE WHEN dtHora BETWEEN 6 AND 12 THEN date(dtTransacao) END) / count(DISTINCT date(dtTransacao)), 4) AS nrPctDiasManha,
                round(count(DISTINCT CASE WHEN dtHora BETWEEN 13 AND 18 THEN date(dtTransacao) END) / count(DISTINCT date(dtTransacao)), 4) AS nrPctDiasTarde,
                round(count(DISTINCT CASE WHEN dtHora BETWEEN 19 AND 24 THEN date(dtTransacao) END) / count(DISTINCT date(dtTransacao)), 4) AS nrPctDiasNoite


        FROM tb_transacao
        GROUP BY IdCliente
),
tb_dia_minuto AS (
        SELECT IdCliente,
                DATE(dtTransacao) AS dtTransacao,
                round((max(float(to_timestamp(dtTransacao))) - min(float(to_timestamp(dtTransacao)))) / 60, 2) AS nrMinutos
        FROM tb_transacao
        GROUP BY IdCliente, DATE(DtTransacao)
),
tb_tempo AS (
        SELECT IdCliente, 
                round(sum(nrMinutos), 2) AS nrQtdeMinutos,
                round(avg(nrMinutos), 2) AS nrAvgMinutos,
                round(sum(nrMinutos) / 4, 2) AS nrAvgMinutoSemana,
                round(sum(nrMinutos) / count(DISTINCT weekofyear(dtTransacao)), 2) AS nrAvgMinutoSemanaAtiva,
                round(count(DISTINCT dtTransacao) / count(DISTINCT weekofyear(dtTransacao)), 2) AS nrQtdeLiveSemanal
        FROM tb_dia_minuto
        GROUP BY IdCliente
)
SELECT '{dt_ref}' AS dtRef,
        dayofweek(date('{dt_ref}')) AS nrDiaSemana,
        dayofmonth(date('{dt_ref}')) AS nrDiaMes,
        weekofyear(date('{dt_ref}')) AS nrSemanaAno,
        month('{dt_ref}')  AS nrMes,
        year('{dt_ref}')  AS nrAno,
        t1.*,
        t2.nrQtdeMinutos,
        t2.nrAvgMinutos,
        t2.nrAvgMinutoSemana,
        t2.nrAvgMinutoSemanaAtiva,
        t2.nrQtdeLiveSemanal
FROM tb_horario AS t1
LEFT JOIN tb_tempo AS t2
ON t1.IdCliente = t2.IdCliente