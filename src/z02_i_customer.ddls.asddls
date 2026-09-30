@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Kunde - Interface View'
define root view entity Z02_I_Customer
  as select from z02_customer

  composition [0..*] of Z02_I_Order  as _Order

{
  key customer_uuid           as CustomerUUID,

      customer_id             as CustomerID,
      company_name            as CompanyName,
      customer_type           as CustomerType,
      street                  as Street,
      postal_code             as PostalCode,
      city                    as City,
      country                 as Country,
      phone                   as Phone,
      email                   as Email,
      price_group             as PriceGroup,
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
      local_last_changed_at   as LocalLastChangedAt,

      _Order
}
