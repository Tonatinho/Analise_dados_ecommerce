USE analise_dados;

/* Desafio 1: A equipe de Logística quer analisar o SLA de entregas e identificar gargalos sem alterar a base bruta. */
CREATE OR REPLACE VIEW vw_analise_entregas AS 
WITH tratativa_logistica AS (
    SELECT
        order_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS dias_entrega,
        CASE
            WHEN order_delivered_customer_date IS NULL THEN 'Pendente'
            ELSE 'Entregue'
        END AS status_ajustado
    FROM olist_orders_dataset
)
SELECT 
    *,
    CASE
        WHEN dias_entrega < 7 THEN 'Rápido'
        WHEN dias_entrega >= 7 AND dias_entrega <= 15 THEN 'Normal'
        WHEN dias_entrega IS NULL THEN 'Pendente'
        ELSE 'Lento'
    END AS performance_logistica
FROM tratativa_logistica;


/* Desafio 2: A equipe de Marketing quer segmentar os produtos por faixa de preço para entender o perfil do portfólio. */
CREATE OR REPLACE VIEW vw_classificacao_precos AS 
WITH classificacao_produtos AS (
    SELECT
        product_id,
        price
    FROM 
        olist_order_items_dataset
)
SELECT 
    *,
    CASE
        WHEN price < 50 THEN 'Barato'
        WHEN price >= 50 AND price <= 500 THEN 'Médio'
        WHEN price > 500 THEN 'Premium'
    END AS classificacao_preco
FROM classificacao_produtos;


/* Scripts de Validação */
SELECT * FROM vw_analise_entregas WHERE performance_logistica = 'Pendente' LIMIT 20;
SELECT * FROM vw_classificacao_precos LIMIT 20;