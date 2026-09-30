@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Auftragsposition - Interface View'
define view entity Z02_I_OrderItem
  as select from z02_order_item

  association        to parent Z02_I_Order as _Order    on $projection.OrderUUID = _Order.OrderUUID

  association [1..1] to Z02_I_Customer     as _Customer on $projection.CustomerUUID = _Customer.CustomerUUID

  association [0..1] to Z02_I_Product      as _Product  on $projection.ProductUUID = _Product.ProductUUID

{
  key item_uuid             as ItemUUID,

      order_uuid            as OrderUUID,
      customer_uuid         as CustomerUUID,
      item_number           as ItemNumber,
      product_uuid          as ProductUUID,

      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      quantity              as Quantity,
      quantity_unit         as QuantityUnit,

      @Semantics.amount.currencyCode: 'Currency'
      net_price             as NetPrice,

      @Semantics.amount.currencyCode: 'Currency'
      item_amount           as ItemAmount,

      @Semantics.amount.currencyCode: 'Currency'
      deposit_total         as DepositTotal,

      currency              as Currency,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Order,
      _Customer,
      _Product
}
