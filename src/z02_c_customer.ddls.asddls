@EndUserText.label: 'Kunde - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity Z02_C_CUSTOMER
  provider contract transactional_query
  as projection on Z02_I_Customer
{
  key CustomerUUID,

      @Search.defaultSearchElement: true
      CustomerID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      CompanyName,

      CustomerType as CustomerCategory,
      Street,
      PostalCode,

      @Search.defaultSearchElement: true
      City,

      Country,
      Phone,
      Email,
      PriceGroup,
      DeletionFlag,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Order : redirected to composition child Z02_C_ORDER
}
