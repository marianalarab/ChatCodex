CLASS zcl_utilities_feature_toggle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_dao      TYPE REF TO zif_utils_feature_toggle_dao OPTIONAL
        i_feature  TYPE zfeature.
    METHODS is_active
      IMPORTING
        i_functionality TYPE zfunctionality
      RETURNING
        VALUE(result)   TYPE boolean.
  PRIVATE SECTION.
    DATA go_dao TYPE REF TO zif_utils_feature_toggle_dao.

    METHODS create_default_dao
      IMPORTING
        i_feature TYPE zfeature
      RETURNING
        VALUE(ro_dao) TYPE REF TO zif_utils_feature_toggle_dao.
ENDCLASS.



CLASS zcl_utilities_feature_toggle IMPLEMENTATION.
  METHOD constructor.
    go_dao = COND #(
      WHEN i_dao IS BOUND THEN i_dao
      ELSE create_default_dao( i_feature ) ).
  ENDMETHOD.

  METHOD is_active.
    result = go_dao->is_active( i_functionality ).
  ENDMETHOD.

  METHOD create_default_dao.
    TEST-SEAM create_default_dao.
      ro_dao = NEW zcl_utils_feature_toggle_dao( i_feature ).
    END-TEST-SEAM.
  ENDMETHOD.
ENDCLASS.
