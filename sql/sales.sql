-- Append data from sales order menu in existing and previous WMS.

select
  a.*
from
(
select
  *
from
  urban-fashion-digital-dwh.tf_db.sales
where
  store not like '%EVENT%' -- Exclude channel "Event"

union all

select
  *
from
  urban-fashion-digital-dwh.tf_db.sales_anch
) as a

left join -- Anti left join with sales retur, in order to get clean sales data.
(
select
  order_number, sku as sku_variant
from
  urban-fashion-digital-dwh.anchanto.returned_b2c_wms

union all

select
  inv_no as order_number, sku_variant
from
  urban-fashion-digital-dwh.tf_db.sales_ret
) as b

on a.inv_no = b.order_number
  and a.sku_variant = b.sku_variant
where
  b.order_number is null
  and b.sku_variant is null
