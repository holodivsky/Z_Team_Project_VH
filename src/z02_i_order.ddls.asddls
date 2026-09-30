@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Auftragskopf - Interface View'
define view entity Z02_I_Order
  as select from z02_order

  composition [0..*] of Z02_I_OrderItem as _Item

  association to parent Z02_I_Customer  as _Customer
    on $projection.CustomerUUID = _Customer.CustomerUUID

{
  key order_uuid              as OrderUUID,

      customer_uuid           as CustomerUUID,
      order_id                as OrderID,
      order_date              as OrderDate,
      delivery_date           as DeliveryDate,

      @Semantics.amount.currencyCode: 'Currency'
      net_amount              as NetAmount,

      @Semantics.amount.currencyCode: 'Currency'
      deposit_total           as DepositTotal,

      currency                as Currency,
      order_status            as OrderStatus,

      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,

      _Customer,
      _Item
}
