/* PROJETO: OLIST E-COMMERCE ANALYTICS (FASE 2)
 FOCO: Criação de Views para Business Intelligence e Análises de Ranking
 DATA: 28/12/2025
*/


/* ---------------------------------------------------------------------------------
 PARTE 1: CRIAÇÃO DE VIEWS (Visualizações para Integração com Power BI)
 O objetivo aqui é deixar as tabelas prontas para o time de Front-end/Dashboard.
 ---------------------------------------------------------------------------------
*/

-- View 1: Auditoria de Pedidos
-- Objetivo: Facilitar o monitoramento do volume de pedidos por status (Entregue, Cancelado, etc.)
CREATE VIEW vw_auditoria_pedidos AS
SELECT 
    order_status AS status_do_pedido, 
    COUNT(*) AS total_pedidos
FROM 
    olist_orders_dataset
GROUP BY 
    order_status
ORDER BY 
    total_pedidos DESC;

-- Teste da View 1
SELECT * FROM vw_auditoria_pedidos;


-- View 2: Clientes de Alto Valor (Pareto)
-- Objetivo: Listar pedidos onde a soma (Preço + Frete) supera R$ 5.000 para ações de fidelidade ou auditoria de fraude
CREATE VIEW vw_pedidos_alto_valor AS
SELECT
	order_id AS id_pedido,
	SUM(price + freight_value) AS valor_total
FROM
	olist_order_items_dataset
GROUP BY 
    order_id
HAVING 
    valor_total > 5000
ORDER BY 
    valor_total DESC;

-- Teste da View 2
SELECT * FROM vw_pedidos_alto_valor;


/* ---------------------------------------------------------------------------------
 PARTE 2: ANÁLISES AVANÇADAS COM WINDOW FUNCTIONS (Rankings)
 O objetivo é classificar vendedores e produtos sem perder dados em caso de empate.
 ---------------------------------------------------------------------------------
*/

-- Análise 1: Ranking de Vendedores por Faturamento
-- Compara a diferença entre RANK (pula posições no empate) e DENSE_RANK (sequencial)
SELECT 
    seller_id,
    SUM(price) AS total_vendido,
    RANK() OVER (ORDER BY SUM(price) DESC) AS ranking_olimpico,      -- Ex: 1, 2, 2, 4...
    DENSE_RANK() OVER (ORDER BY SUM(price) DESC) AS ranking_denso    -- Ex: 1, 2, 2, 3...
FROM 
    olist_order_items_dataset
GROUP BY 
    seller_id
ORDER BY 
    total_vendido DESC;


-- Análise 2: Ranking de Produtos Mais Vendidos (Best Sellers)
-- Identificação dos produtos campeões de venda utilizando DENSE_RANK para manter a sequência justa
SELECT 
	product_id,
	COUNT(*) AS total_pedidos,
	DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking_vendas
FROM 
	olist_order_items_dataset
GROUP BY
	product_id
ORDER BY
	total_pedidos DESC;