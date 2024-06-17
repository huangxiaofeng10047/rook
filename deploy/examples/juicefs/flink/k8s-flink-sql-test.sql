CREATE TABLE Orders (
    order_number BIGINT,
    price        DECIMAL(32,2),
    order_time   TIMESTAMP(3),
    PRIMARY KEY (order_number) NOT ENFORCED
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '10'
);

CREATE TABLE Orders_hudi (
    order_number BIGINT,
    price        DECIMAL(32,2),
    order_time   TIMESTAMP(3),
    PRIMARY KEY (order_number) NOT ENFORCED
) WITH (
  'connector' = 'hudi',
  'path' = 'jfs://ceph-bkt-630d0187-3ddf-43da-a5a7-e9dd764b92f4/orders_hudi_2',
  'table.type' = 'MERGE_ON_READ'
);

insert into Orders_hudi select * from Orders;
