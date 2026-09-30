CLASS z02_cl_fill_product DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS z02_cl_fill_product IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DELETE FROM z02_product.

    DATA lt_product TYPE TABLE OF z02_product.

    TRY.
        lt_product = VALUE #(
          ( product_uuid = cl_system_uuid=>create_uuid_x16_static( )
            product_id = 'P-1001' beer_name = 'Nürnberger Helles'
            beer_style = 'HELL' alcohol_content = '4.9' original_gravity = '11.8'
            container_type = 'F030' filling_volume = '30.00' filling_unit = 'L'
            list_price = '78.00' deposit_amount = '30.00' currency = 'EUR' )

          ( product_uuid = cl_system_uuid=>create_uuid_x16_static( )
            product_id = 'P-1002' beer_name = 'Fränkisches Pils'
            beer_style = 'PILS' alcohol_content = '4.8' original_gravity = '11.5'
            container_type = 'F050' filling_volume = '50.00' filling_unit = 'L'
            list_price = '124.00' deposit_amount = '30.00' currency = 'EUR' )

          ( product_uuid = cl_system_uuid=>create_uuid_x16_static( )
            product_id = 'P-1003' beer_name = 'Weizen Naturtrüb'
            beer_style = 'WEIZ' alcohol_content = '5.4' original_gravity = '12.4'
            container_type = 'FL05' filling_volume = '0.50' filling_unit = 'L'
            list_price = '1.15' deposit_amount = '0.08' currency = 'EUR' )

          ( product_uuid = cl_system_uuid=>create_uuid_x16_static( )
            product_id = 'P-1004' beer_name = 'Winterbock Dunkel'
            beer_style = 'BOCK' alcohol_content = '6.8' original_gravity = '16.5'
            container_type = 'FL33' filling_volume = '0.33' filling_unit = 'L'
            list_price = '1.45' deposit_amount = '0.08' currency = 'EUR' )

          ( product_uuid = cl_system_uuid=>create_uuid_x16_static( )
            product_id = 'P-1005' beer_name = 'Sommer Radler'
            beer_style = 'SAIS' alcohol_content = '2.5' original_gravity = '7.2'
            container_type = 'K020' filling_volume = '20.00' filling_unit = 'L'
            list_price = '46.00' deposit_amount = '25.00' currency = 'EUR' )
        ).
      CATCH cx_uuid_error INTO DATA(lx_uuid).
        out->write( |Fehler: { lx_uuid->get_text( ) }| ).
    ENDTRY.

    LOOP AT lt_product ASSIGNING FIELD-SYMBOL(<ls>).
      GET TIME STAMP FIELD DATA(lv_ts).
      <ls>-created_by = sy-uname.
      <ls>-created_at = lv_ts.
      <ls>-last_changed_by = sy-uname.
      <ls>-last_changed_at = lv_ts.
      <ls>-local_last_changed_at = lv_ts.
    ENDLOOP.

    INSERT z02_product FROM TABLE @lt_product.

    out->write( |{ sy-dbcnt } Produkte eingefügt| ).

  ENDMETHOD.
ENDCLASS.
