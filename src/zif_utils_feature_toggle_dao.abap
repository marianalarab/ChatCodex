INTERFACE zif_utils_feature_toggle_dao PUBLIC.
  METHODS is_active
    IMPORTING
      i_functionality TYPE zfunctionality
    RETURNING
      VALUE(result)   TYPE boolean.
ENDINTERFACE.
