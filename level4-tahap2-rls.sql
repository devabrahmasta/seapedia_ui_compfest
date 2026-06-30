create policy "update_orders_seller"
on orders for update
using (store_id in (select id from stores where seller_id = auth.uid()))
with check (store_id in (select id from stores where seller_id = auth.uid()));

create policy "insert_order_status_history_seller"
on order_status_history for insert
with check (
  order_id in (
    select id from orders where store_id in (
      select id from stores where seller_id = auth.uid()
    )
  )
);
