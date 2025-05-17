-- Append sales data from POS menu from existing and previous WMS

select
  a.*
from
  urban-fashion-digital-dwh.tf_db.pos_sales as a 
left join
  urban-fashion-digital-dwh.tf_db.pos_ret as b
  on a.invoice_no = b.invoice_no
where
  b.invoice_no is null -- Anti left join to exclude return

union all

select
  cast(order_date as date) as inv_date, 'EVENT' as wh_desc, 
  concat(channel, '//', store) as store, order_number,
  'N/A' as member_id, 'N/A' as sales_name, sku as sku_variant,
  split(sku, '/')[safe_offset(0)] as msku,
  split(sku, '/')[safe_offset(1)] as size,
  cast(ordered_quantity as int64) as qty, cast(selling_price as int64) as price,
  0 as disc1_amount, 0 as disc2_amount, 0 as nett_product, 0 as voucher_amount,
  0 as other_disc_amount, 0 as total_gross_product
from
  urban-fashion-digital-dwh.anchanto.b2b_consignment
