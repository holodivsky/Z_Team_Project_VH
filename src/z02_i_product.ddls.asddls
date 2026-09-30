@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Produkt - Interface View'
define view entity Z02_I_Product
  as select from z02_product
{
  key product_uuid            as ProductUUID,

      product_id              as ProductID,
      beer_name               as BeerName,
      beer_style              as BeerStyle,
      alcohol_content         as AlcoholContent,
      original_gravity        as OriginalGravity,
      container_type          as ContainerType,

      @Semantics.quantity.unitOfMeasure: 'FillingUnit'
      filling_volume          as FillingVolume,
      filling_unit            as FillingUnit,

      @Semantics.amount.currencyCode: 'Currency'
      list_price              as ListPrice,

      @Semantics.amount.currencyCode: 'Currency'
      deposit_amount          as DepositAmount,

      currency                as Currency,
      deletion_flag           as DeletionFlag,

      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt
}
