with df as
(select
  id, so_date order_date, pl_date picking_date, 
  inv_no order_number, do_no, split(expedition, '/')[offset(0)] carrier,
  status order_status, xmor_store,
  case 
    when lower(store) like '%sneakers%' then 'Sneakers Dept'
    when lower(store) like '%fashion%' then 'Ifashion Sports'
    when lower(channel) = 'staff' then 'Sneakers Dept'
    when lower(channel) = 'customer os selling' then 'Sneakers Dept'
    when lower(notes) like '%kick avenue%' then 'Consignment'
    when lower(notes) like '%kick avanue%' then 'Consignment'
    when lower(notes) like '%looking best%' then 'Consignment'
    else initcap(store)
  end as store,
  case
    when lower(channel) = 'staff' then 'Staff'
    when lower(channel) = 'customer os selling' then 'Whatsapp'
    when lower(channel) = 'tiktok' then 'TikTok'
    when lower(channel) = 'bakaran marketing' then 'Marketing'
    when lower(notes) like '%looking best%' then 'Looking Best'
    when lower(notes) like '%kick avenue%' then 'Kick Avenue'
    when lower(notes) like '%kick avanue%' then 'Kick Avenue'
    else channel
  end as channel,
  sku_variant sku, msku, size, article_name, brand, category, 
  sub_category, qty_order quantity, price, cost_value, notes

from
  (select 
    vs.id, so_date, pl_date, inv_no, do_no, expedition, initcap(status_name) status, store as xmor_store,
    SPLIT(store, ';')[OFFSET(0)] channel,
    IF(ARRAY_LENGTH(SPLIT(store, ';')) > 1, SPLIT(store, ';')[OFFSET(1)], NULL) AS store, 
    vs.sku_variant,
    SPLIT(vs.sku_variant, '/')[OFFSET(0)] msku,
    IF(ARRAY_LENGTH(SPLIT(vs.sku_variant, '/')) > 1, SPLIT(vs.sku_variant, '/')[OFFSET(1)], NULL) AS size, 
    article_name, brand, category, sub_category, qty_order, price, last_hpp as cost_value, notes
  from 
    (
      select * from urban-fashion-digital-dwh.postgres_udc.ufd_sales
      -- where true qualify row_number() over (partition by so_no, sku_variant order by created_at desc) = 1
    ) vs
  left join
    urban-fashion-digital-dwh.cleaned_data.master_sku ms
    on split(sku_variant, '/')[offset(0)] = ms.msku
  left join
    urban-fashion-digital-dwh.cleaned_data.msku_avg_costprice ac
    on SPLIT(vs.sku_variant, '/')[OFFSET(0)] = ac.msku)

where lower(msku) not like '%doublebox%')

select 
  a.* except(picking_date, size, brand, 
  xmor_store, notes, carrier, category, sub_category), sell_price, 
  price - sell_price as price_diff, b.age_day, b.age_cat,
  price - cost_value as gross_profit, round(safe_divide((price - cost_value), price), 4) as gpm
from
  df a
left join
  urban-fashion-digital-dwh.cleaned_data.age b
  on a.msku = b.msku
left join
  urban-fashion-digital-dwh.cleaned_data.last_sellprice as c
  on a.msku = c.msku
where 
  true qualify row_number() over (partition by id order by id desc) = 1
order by 
  1 asc
