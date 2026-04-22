CLASS zcl_utils_feature_toggle_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  GLOBAL FRIENDS zcl_utilities_feature_toggle.

  PUBLIC SECTION.
    INTERFACES zif_utils_feature_toggle_dao.

    METHODS constructor
      IMPORTING
        i_feature TYPE zfeature.
  PROTECTED SECTION.
    DATA gv_feature TYPE zfeature.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_utils_feature_toggle_dao IMPLEMENTATION.
  METHOD constructor.
    gv_feature = i_feature.
  ENDMETHOD.

  METHOD zif_utils_feature_toggle_dao~is_active.
    SELECT SINGLE 'X'
      FROM zfeat_flag_activ
      INTO @result
      WHERE feature       = @gv_feature
        AND functionality = @i_functionality
        AND active        = @abap_true.
  ENDMETHOD.
ENDCLASS.
