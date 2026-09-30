CLASS lhc_Customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Customer RESULT result.
ENDCLASS.

CLASS lhc_Customer IMPLEMENTATION.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_Order DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setOrderID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Order~setOrderID.

    METHODS setInitialValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Order~setInitialValues.

    METHODS validateDeliveryDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Order~validateDeliveryDate.
ENDCLASS.

CLASS lhc_Order IMPLEMENTATION.

  METHOD setOrderID.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY Order
        FIELDS ( OrderID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DELETE lt_orders WHERE OrderID IS NOT INITIAL.
    CHECK lt_orders IS NOT INITIAL.

    SELECT SINGLE FROM z02_order FIELDS MAX( order_id ) INTO @DATA(lv_max).
    DATA(lv_next) = COND i( WHEN lv_max IS INITIAL THEN 0 ELSE CONV i( lv_max ) ).

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).
      lv_next += 1.
      <ls_order>-OrderID = |{ CONV z02_order-order_id( lv_next ) ALPHA = IN WIDTH = 10 }|.
    ENDLOOP.

    MODIFY ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY Order
        UPDATE FIELDS ( OrderID )
        WITH CORRESPONDING #( lt_orders )
      REPORTED DATA(lt_rep).

  ENDMETHOD.


  METHOD setInitialValues.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY Order
        FIELDS ( OrderStatus OrderDate Currency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DATA lt_update TYPE TABLE FOR UPDATE z02_i_customer\\Order.

    LOOP AT lt_orders INTO DATA(ls).
      IF ls-OrderStatus IS INITIAL.
        ls-OrderStatus = 'E'.
      ENDIF.
      IF ls-OrderDate IS INITIAL.
        ls-OrderDate = cl_abap_context_info=>get_system_date( ).
      ENDIF.
      IF ls-Currency IS INITIAL.
        ls-Currency = 'EUR'.
      ENDIF.
      APPEND VALUE #( %tky        = ls-%tky
                      OrderStatus = ls-OrderStatus
                      OrderDate   = ls-OrderDate
                      Currency    = ls-Currency ) TO lt_update.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY Order
        UPDATE FIELDS ( OrderStatus OrderDate Currency )
        WITH lt_update
      REPORTED DATA(lt_rep).

  ENDMETHOD.


  METHOD validateDeliveryDate.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY Order
        FIELDS ( DeliveryDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    LOOP AT lt_orders INTO DATA(ls_order).

      IF ls_order-DeliveryDate IS INITIAL.
        APPEND VALUE #( %tky = ls_order-%tky ) TO failed-order.
        APPEND VALUE #( %tky = ls_order-%tky
                        %element-DeliveryDate = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Lieferdatum ist ein Pflichtfeld' )
                      ) TO reported-order.

      ELSEIF ls_order-DeliveryDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = ls_order-%tky ) TO failed-order.
        APPEND VALUE #( %tky = ls_order-%tky
                        %element-DeliveryDate = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Lieferdatum darf nicht in der Vergangenheit liegen' )
                      ) TO reported-order.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


CLASS lhc_OrderItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setCustomerUUID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR OrderItem~setCustomerUUID.

    METHODS setItemNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR OrderItem~setItemNumber.

    METHODS setItemDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR OrderItem~setItemDefaults.

    METHODS calculateItemAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR OrderItem~calculateItemAmount.

    METHODS calculateOrderTotals FOR DETERMINE ON MODIFY
      IMPORTING keys FOR OrderItem~calculateOrderTotals.

    METHODS validateQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR OrderItem~validateQuantity.

    METHODS validateProduct FOR VALIDATE ON SAVE
      IMPORTING keys FOR OrderItem~validateProduct.
ENDCLASS.

CLASS lhc_OrderItem IMPLEMENTATION.

  METHOD setCustomerUUID.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem BY \_Order
        FIELDS ( CustomerUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders)
      LINK DATA(lt_link).

    DATA lt_update TYPE TABLE FOR UPDATE z02_i_customer\\OrderItem.

    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_link) = VALUE #( lt_link[ source-%tky = ls_key-%tky ] OPTIONAL ).
      CHECK ls_link IS NOT INITIAL.
      DATA(ls_order) = VALUE #( lt_orders[ %tky = ls_link-target-%tky ] OPTIONAL ).
      CHECK ls_order-CustomerUUID IS NOT INITIAL.
      APPEND VALUE #( %tky         = ls_key-%tky
                      CustomerUUID = ls_order-CustomerUUID ) TO lt_update.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        UPDATE FIELDS ( CustomerUUID )
        WITH lt_update
      REPORTED DATA(lt_rep).

  ENDMETHOD.


  METHOD setItemNumber.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem BY \_Order
        FIELDS ( OrderUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    SORT lt_orders BY OrderUUID.
    DELETE ADJACENT DUPLICATES FROM lt_orders COMPARING OrderUUID.

    DATA lt_update TYPE TABLE FOR UPDATE z02_i_customer\\OrderItem.

    LOOP AT lt_orders INTO DATA(ls_order).

      READ ENTITIES OF z02_i_customer IN LOCAL MODE
        ENTITY Order BY \_Item
          FIELDS ( ItemNumber )
          WITH VALUE #( ( %tky = ls_order-%tky ) )
        RESULT DATA(lt_items).

      DATA(lv_no) = 0.
      LOOP AT lt_items INTO DATA(ls_item) WHERE ItemNumber IS NOT INITIAL.
        IF ls_item-ItemNumber > lv_no.
          lv_no = ls_item-ItemNumber.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_items INTO ls_item WHERE ItemNumber IS INITIAL.
        lv_no += 10.
        APPEND VALUE #( %tky       = ls_item-%tky
                        ItemNumber = lv_no ) TO lt_update.
      ENDLOOP.

    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        UPDATE FIELDS ( ItemNumber )
        WITH lt_update
      REPORTED DATA(lt_rep).

  ENDMETHOD.


  METHOD setItemDefaults.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        FIELDS ( ProductUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE z02_i_customer\\OrderItem.

    LOOP AT lt_items INTO DATA(ls_item).

      CHECK ls_item-ProductUUID IS NOT INITIAL.

      SELECT SINGLE FROM z02_product
        FIELDS list_price, currency, filling_unit
        WHERE product_uuid = @ls_item-ProductUUID
        INTO @DATA(ls_prod).

      CHECK sy-subrc = 0.

      APPEND VALUE #( %tky         = ls_item-%tky
                      NetPrice     = ls_prod-list_price
                      Currency     = ls_prod-currency
                      QuantityUnit = ls_prod-filling_unit ) TO lt_update.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        UPDATE FIELDS ( NetPrice Currency QuantityUnit )
        WITH lt_update
      REPORTED DATA(lt_rep).

  ENDMETHOD.


  METHOD calculateItemAmount.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        FIELDS ( ProductUUID Quantity NetPrice )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE z02_i_customer\\OrderItem.

    LOOP AT lt_items INTO DATA(ls_item).

      DATA(lv_deposit) = CONV z02_order_item-deposit_total( 0 ).

      IF ls_item-ProductUUID IS NOT INITIAL.
        SELECT SINGLE FROM z02_product
          FIELDS deposit_amount
          WHERE product_uuid = @ls_item-ProductUUID
          INTO @DATA(lv_dep_unit).
        IF sy-subrc = 0.
          lv_deposit = lv_dep_unit * ls_item-Quantity.
        ENDIF.
      ENDIF.

      APPEND VALUE #( %tky         = ls_item-%tky
                      ItemAmount   = ls_item-NetPrice * ls_item-Quantity
                      DepositTotal = lv_deposit ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        UPDATE FIELDS ( ItemAmount DepositTotal )
        WITH lt_update
      REPORTED DATA(lt_rep).

  ENDMETHOD.


  METHOD calculateOrderTotals.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem BY \_Order
        FIELDS ( OrderUUID Currency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    SORT lt_orders BY OrderUUID.
    DELETE ADJACENT DUPLICATES FROM lt_orders COMPARING OrderUUID.

    DATA lt_upd_order TYPE TABLE FOR UPDATE z02_i_customer\\Order.

    LOOP AT lt_orders INTO DATA(ls_order).

      READ ENTITIES OF z02_i_customer IN LOCAL MODE
        ENTITY Order BY \_Item
          FIELDS ( ItemAmount DepositTotal Currency )
          WITH VALUE #( ( %tky = ls_order-%tky ) )
        RESULT DATA(lt_items).

      DATA(lv_net)     = CONV z02_order-net_amount( 0 ).
      DATA(lv_deposit) = CONV z02_order-deposit_total( 0 ).
      DATA(lv_curr)    = ls_order-Currency.

      LOOP AT lt_items INTO DATA(ls_item).
        lv_net     += ls_item-ItemAmount.
        lv_deposit += ls_item-DepositTotal.
        IF lv_curr IS INITIAL AND ls_item-Currency IS NOT INITIAL.
          lv_curr = ls_item-Currency.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #( %tky         = ls_order-%tky
                      NetAmount    = lv_net
                      DepositTotal = lv_deposit
                      Currency     = lv_curr ) TO lt_upd_order.
    ENDLOOP.

    CHECK lt_upd_order IS NOT INITIAL.

    MODIFY ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY Order
        UPDATE FIELDS ( NetAmount DepositTotal Currency )
        WITH lt_upd_order
      REPORTED DATA(lt_rep).

  ENDMETHOD.


  METHOD validateQuantity.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        FIELDS ( Quantity )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-Quantity <= 0.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-orderitem.
        APPEND VALUE #( %tky = ls_item-%tky
                        %element-Quantity = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Die Menge muss größer als null sein' )
                      ) TO reported-orderitem.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD validateProduct.

    READ ENTITIES OF z02_i_customer IN LOCAL MODE
      ENTITY OrderItem
        FIELDS ( ProductUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-ProductUUID IS INITIAL.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-orderitem.
        APPEND VALUE #( %tky = ls_item-%tky
                        %element-ProductUUID = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Bitte ein Produkt auswählen' )
                      ) TO reported-orderitem.
        CONTINUE.
      ENDIF.

      SELECT SINGLE FROM z02_product FIELDS product_uuid
        WHERE product_uuid = @ls_item-ProductUUID
        INTO @DATA(lv_dummy).

      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-orderitem.
        APPEND VALUE #( %tky = ls_item-%tky
                        %element-ProductUUID = if_abap_behv=>mk-on
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Produkt existiert nicht' )
                      ) TO reported-orderitem.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
