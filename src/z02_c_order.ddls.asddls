@EndUserText.label: 'Auftragskopf - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity Z02_C_ORDER
  as projection on Z02_I_Order
{
  key OrderUUID,

      CustomerUUID,

      @Search.defaultSearchElement: true
      OrderID,

      OrderDate,
      DeliveryDate,

      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,

      @Semantics.amount.currencyCode: 'Currency'
      DepositTotal,

      Currency,
      OrderStatus,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Customer : redirected to parent Z02_C_CUSTOMER,
      _Item     : redirected to composition child Z02_C_ORDERITEM
}
