use analise_dados;


-- 1. INVESTIGAÇÃO PRELIMINAR
-- Verificando como os dados vieram no CSV
select 
	order_purchase_timestamp 
from 
	olist_orders_dataset 
limit 5;


-- Testando se a conversão direta funcionaria (teste de tipo)
select 
    order_id,
    CAST(order_purchase_timestamp as DATETIME) as data_teste
from 
    olist_orders_dataset
limit 5;


-- 2. TENTATIVA DE ALTERAÇÃO DIRETA (LOG DE ERRO)

 /* Tentativa inicial de mudar o tipo para DATETIME:
 ALTER TABLE olist_orders_dataset MODIFY order_purchase_timestamp DATETIME;

 -- RESULTADO: ERRO "Incorrect datetime value: ''"
 -- CAUSA: O banco encontrou aspas vazias ('') e travou porque vazio não é data.
 -- AÇÃO NECESSÁRIA: Converter vazios para NULL antes de alterar.
 */


-- 3. CORREÇÃO DOS DADOS (DATA CLEANING)
-- Solução: transformar textos vazios ('') em nulos (NULL)

-- Limpeza na tabela de Pedidos
UPDATE olist_orders_dataset SET order_approved_at = NULL WHERE order_approved_at = '';
UPDATE olist_orders_dataset SET order_delivered_carrier_date = NULL WHERE order_delivered_carrier_date = '';
UPDATE olist_orders_dataset SET order_delivered_customer_date = NULL WHERE order_delivered_customer_date = '';


-- Limpeza na tabela de Itens
UPDATE olist_order_items_dataset SET shipping_limit_date = NULL WHERE shipping_limit_date = '';


-- 4. APLICAÇÃO DA MUDANÇA DE SCHEMA (SUCESSO)

-- Com os dados limpos, a alteração de tipo funcionou:

ALTER TABLE olist_orders_dataset 
MODIFY order_purchase_timestamp DATETIME,
MODIFY order_approved_at DATETIME,
MODIFY order_delivered_carrier_date DATETIME,
MODIFY order_delivered_customer_date DATETIME,
MODIFY order_estimated_delivery_date DATETIME;

ALTER TABLE olist_order_items_dataset
MODIFY shipping_limit_date DATETIME;


-- MISSÃO 1: AUDITORIA DE PEDIDOS

-- ANÁLISE DE VOLUMETRIA: quantidade de pedidos por status atual
select 
    order_status as status_do_pedido, 
    count(*) as total_pedidos
from olist_orders_dataset
group by order_status
order by total_pedidos desc;


-- MISSÃO 2: FATURAMENTO TOTAL

-- KPI FINANCEIRO: valor total acumulado em vendas e fretes (histórico completo)
select
	SUM(price) as Valor_total,
	SUM(freight_value) as Valor_frete
from
	olist_order_items_dataset ooi;


-- MISSÃO 3: PERFORMANCE LOGÍSTICA

-- 1. RANKING: identificando o pedido com mais itens (o "Atacadista")
select 
	order_id,
	count(*) as total_itens
from
	olist_order_items_dataset ooi
group by order_id 
order by total_itens DESC
limit 10;


-- 2. KPI: média global de itens por pedido (Basket Size)
SELECT 
    COUNT(*) as total_itens,
    COUNT(DISTINCT order_id) as total_pedidos,
    COUNT(*) / COUNT(DISTINCT order_id) as media_itens_por_pedido
FROM 
    olist_order_items_dataset;


-- MISSÃO 4: EVOLUÇÃO TEMPORAL (TIME SERIES)

-- ANÁLISE DE CRESCIMENTO: volume de pedidos por ano
select
	count(*) as total_de_pedidos,
	year(order_purchase_timestamp) as Ano
from
	olist_orders_dataset 
group by year(order_purchase_timestamp)
order by Ano asc;


-- MISSÃO 5: CLIENTES DE ALTO VALOR (PARETO)

-- Auditoria: listando pedidos onde a soma (Preço + Frete) ultrapassa R$ 5.000
select
	order_id as id_pedido,
	sum(price + freight_value) as valor_total
from
	olist_order_items_dataset
group by order_id
having valor_total > 5000
order by valor_total desc;
