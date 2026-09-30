@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Auftragsposition - Projection View'
@Metadata.allowExtensions: true
define view entity Z02_C_ORDERITEM
  as projection on Z02_I_OrderItem
{
  key ItemUUID,
      OrderUUID,
      CustomerUUID,
      ItemNumber,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'Z02_I_Product',
                                                       element: 'ProductUUID' } }]
      ProductUUID,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      Quantity,
      QuantityUnit,
      @Semantics.amount.currencyCode: 'Currency'
      NetPrice,
      @Semantics.amount.currencyCode: 'Currency'
      ItemAmount,
      @Semantics.amount.currencyCode: 'Currency'
      DepositTotal,
      Currency,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Order    : redirected to parent Z02_C_ORDER,
      _Customer : redirected to Z02_C_CUSTOMER,
      _Product
}
