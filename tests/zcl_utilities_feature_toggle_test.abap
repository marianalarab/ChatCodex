CLASS ltc_utilities_feature_toggle DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS gc_feature       TYPE zfeature        VALUE 'FEAT'.
    CONSTANTS gc_functionality TYPE zfunctionality  VALUE 'FUNC'.

    METHODS constructor_uses_provided_dao FOR TESTING.
    METHODS constructor_builds_default_dao FOR TESTING.
    METHODS is_active_delegates_dao FOR TESTING.
ENDCLASS.



CLASS lcl_spy_dao DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_utils_feature_toggle_dao.

    METHODS set_return_value
      IMPORTING
        i_value TYPE boolean.
    METHODS was_called
      RETURNING
        VALUE(result) TYPE abap_bool.

    DATA last_functionality TYPE zfunctionality.
  PRIVATE SECTION.
    DATA mv_result TYPE boolean VALUE abap_false.
    DATA mv_called TYPE abap_bool VALUE abap_false.
ENDCLASS.



CLASS lcl_spy_dao IMPLEMENTATION.
  METHOD set_return_value.
    mv_result = i_value.
  ENDMETHOD.

  METHOD was_called.
    result = mv_called.
  ENDMETHOD.

  METHOD zif_utils_feature_toggle_dao~is_active.
    mv_called = abap_true.
    last_functionality = i_functionality.
    result = mv_result.
  ENDMETHOD.
ENDCLASS.



CLASS lcl_recording_dao DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_utils_feature_toggle_dao.

    CLASS-DATA last_feature TYPE zfeature.
    CLASS-DATA instantiation_count TYPE i.

    METHODS constructor
      IMPORTING
        i_feature TYPE zfeature OPTIONAL.
    CLASS-METHODS reset.
  PRIVATE SECTION.
ENDCLASS.



CLASS lcl_recording_dao IMPLEMENTATION.
  METHOD constructor.
    instantiation_count = instantiation_count + 1.
    last_feature = i_feature.
  ENDMETHOD.

  METHOD zif_utils_feature_toggle_dao~is_active.
    result = abap_false.
  ENDMETHOD.

  METHOD reset.
    CLEAR: instantiation_count, last_feature.
  ENDMETHOD.
ENDCLASS.



CLASS ltc_utilities_feature_toggle IMPLEMENTATION.
  METHOD constructor_uses_provided_dao.
    DATA(lo_spy) = NEW lcl_spy_dao( ).
    DATA(lo_dao) TYPE REF TO zif_utils_feature_toggle_dao.
    lo_dao = lo_spy.
    lo_spy->set_return_value( abap_true ).

    DATA(lo_sut) = NEW zcl_utilities_feature_toggle(
      i_dao     = lo_dao
      i_feature = gc_feature ).

    DATA(lv_result) = lo_sut->is_active( gc_functionality ).

    cl_abap_unit_assert=>assert_true(
      act = lo_spy->was_called( )
      msg = 'DAO injetado deve ser utilizado.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_spy->last_functionality
      exp = gc_functionality
      msg = 'Funcionalidade deve ser repassada ao DAO.' ).

    cl_abap_unit_assert=>assert_true(
      act = lv_result
      msg = 'Retorno deve refletir valor provido pelo DAO.' ).
  ENDMETHOD.

  METHOD constructor_builds_default_dao.
    lcl_recording_dao=>reset( ).

    TEST-INJECTION create_default_dao.
      ro_dao = NEW lcl_recording_dao( i_feature = i_feature ).
    END-TEST-INJECTION.

    DATA(lo_sut) = NEW zcl_utilities_feature_toggle( i_feature = gc_feature ).

    cl_abap_unit_assert=>assert_equals(
      act = lcl_recording_dao=>instantiation_count
      exp = 1
      msg = 'Instância padrão do DAO deve ser criada uma única vez.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lcl_recording_dao=>last_feature
      exp = gc_feature
      msg = 'Feature informada deve ser repassada à criação do DAO padrão.' ).
  ENDMETHOD.

  METHOD is_active_delegates_dao.
    DATA(lo_spy) = NEW lcl_spy_dao( ).
    DATA(lo_dao) TYPE REF TO zif_utils_feature_toggle_dao.
    lo_dao = lo_spy.
    lo_spy->set_return_value( abap_false ).

    DATA(lo_sut) = NEW zcl_utilities_feature_toggle(
      i_dao     = lo_dao
      i_feature = gc_feature ).

    DATA(lv_result) = lo_sut->is_active( gc_functionality ).

    cl_abap_unit_assert=>assert_false(
      act = lv_result
      msg = 'Resultado deve refletir valor retornado pelo DAO.' ).

    cl_abap_unit_assert=>assert_true(
      act = lo_spy->was_called( )
      msg = 'Método IS_ACTIVE deve delegar execução ao DAO.' ).
  ENDMETHOD.
ENDCLASS.
