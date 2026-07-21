class ltcl_function_double_examples definition final for testing duration short risk level harmless.

  private section.
    class-data expense_manager type ref to cl_ftd_expense_manager.
    class-data function_test_environment type ref to if_function_test_environment.

    class-methods class_setup raising cx_static_check.

    methods setup raising cx_static_check.

    methods default_behavior for testing raising cx_static_check.
    methods simple_configuration for testing raising cx_static_check.
    methods more_configurations for testing raising cx_static_check.
    methods chaining_outputs for testing raising cx_static_check.
    methods non_configured_parameters for testing raising cx_static_check.
    methods for_times_configuration for testing raising cx_static_check.
    methods last_configuration_behavior for testing raising cx_static_check.
    methods ignore_all_parameters for testing raising cx_static_check.
    methods raise_classic_exception for testing raising cx_static_check.
    methods raise_exception for testing raising cx_static_check.
    methods behavior_verification for testing raising cx_static_check.
    methods argument_matcher for testing raising cx_static_check.
    methods custom_answer for testing raising cx_static_check.
    methods disable_testdouble for testing raising cx_static_check.


    methods get_conv_curr_input_config
      importing
        currency_converter type ref to if_function_testdouble
        amount             type i
        source_currency    type string
        target_currency    type string
      returning
        value(result) type ref to if_ftd_input_configuration.

    methods get_conv_curr_output_config
      importing
        currency_converter type ref to if_function_testdouble
        target_curr_amount type i
      returning
        value(result) type ref to if_ftd_output_configuration.

    methods get_conv_to_base_curr_i_config
      importing
        base_curr_converter type ref to if_function_testdouble
        amount             type i
        source_currency    type string
      returning
        value(result) type ref to if_ftd_input_configuration.

    methods get_conv_to_base_curr_o_config
      importing
        base_curr_converter type ref to if_function_testdouble
        base_curr_amount type i
      returning
        value(result) type ref to if_ftd_output_configuration.

endclass.

class ltcl_function_double_examples implementation.

  method class_setup.
    expense_manager = new cl_ftd_expense_manager( ).

    " create function test double environment with a list of function modules for which test doubles needs to be created.
    " Each test double could be configured as required for a test use-case.

    " keep in mind, the test doubles created for the given function modules would be active for the entire test session
    " and any CALL FUNCTION statement on actual function module would get replaced with the corresponding test double in the session.
    function_test_environment = cl_function_test_environment=>create( value #( ( 'FTD_CONVERT_CURRENCY' )
                                                                               ( 'FTD_CONVERT_TO_BASE_CURRENCY' ) ) ).
  endmethod.

  method setup.
    expense_manager->clear_expenses( ).

    " clear all configurations on test doubles
    function_test_environment->clear_doubles( ).
  endmethod.

  method default_behavior.
    " How a test double behave if it is not configured yet.

    " add expenses
    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 200 ).

    " default behavior of a test double if not configured, is to return initial values for all exporting parameters
    " and same value as input for changing and table parameters, meaning the test double will behave as if there is no logic.

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = total_expense ).

    " since there are two expenses recorded, the function module will get invoked 2 times. Verify the expectation.
    function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' )->verify( )->is_called_times( 2 ).
  endmethod.

  method simple_configuration.

    " Let's start configuring the test double to return some output when invoked with a specific set of input values.

    " add expenses
    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 200 ).

    " to configure a test double, first we need to get the double from the test environment
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " to configure a test double,
    " 1. we need to create the input configuration which would contain the expected set of input values on function call
    " 2. we need to create the output configuration which would contain the output values expected on function call
    "    for the given input values.
    " 3. configure test double with input and output test data configuration

    " input test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    " output test data configuration
    data(conv_curr_output_config) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                 target_curr_amount = 80 ).

    " configure test double to return the values configured in the output configuration "conv_curr_output_config"
    " when the function module is invoked with the exact list of input arguments defined in "conv_curr_input_config"
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    " input test data configuration - for amount 200
    conv_curr_input_config = get_conv_curr_input_config( currency_converter = currency_converter
                                                         amount = 200 source_currency = 'USD' target_currency = 'EUR' ).

    " output test data configuration
    conv_curr_output_config = get_conv_curr_output_config( currency_converter = currency_converter
                                                           target_curr_amount = 160 ).

    " configure test double for the new input and output test data
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 240 act = total_expense ).


    " what happens when a function is invoked with an input configuration which is not configured.
    " test double would resort to the default behavior as explained in test method "default_behavior()"

    " add a new expense 300, which is not configured in test double
    expense_manager->add_expense( description = 'Expense 3' currency_code = 'USD' amount = 300 ).

    " no change in total expense as for input "300", since nothing is configured, zero would be returned as output
    total_expense = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 240 act = total_expense ).
  endmethod.

  method more_configurations.

    " How to configure the test double to return different outputs on different set of inputs.

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 3' currency_code = 'USD' amount = 200 ).
    expense_manager->add_expense( description = 'Expense 4' currency_code = 'USD' amount = 200 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    data(conv_curr_output_config) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                   target_curr_amount = 80 ).


    " configure test double to return the output target_curr_amount as "80" for input "100, USD, EUR"
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).


    " test data configuration - for amount 200
    conv_curr_input_config = get_conv_curr_input_config( currency_converter = currency_converter
                                                         amount = 200 source_currency = 'USD' target_currency = 'EUR' ).

    conv_curr_output_config = get_conv_curr_output_config( currency_converter = currency_converter
                                                             target_curr_amount = 160 ).


    " configure test double to return the output target_curr_amount as "160" for input "200, USD, EUR"
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    " test
    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 480 act = total_expense ).
  endmethod.

  method chaining_outputs.

    " How to configure test double to return different outputs for the same input on subsequent invocations.

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 3' currency_code = 'USD' amount = 100 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    data(conv_curr_output_config_1) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                   target_curr_amount = 80 ).
    data(conv_curr_output_config_2) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                   target_curr_amount = 90 ).

    " configure test double to return the output "80" for the first invocation and
    " "85" for the second invocation onwards for input "100, USD, EUR"
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config_1
                                                                        )->then_set_output( conv_curr_output_config_2 ).

    " test
    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 260 act = total_expense ).
  endmethod.

  method for_times_configuration.

    " While method chaining multiple outputs for the same input, it is also possible to define,
    " how many times each output to be returned on function invocation using the api "for_times()"

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 3' currency_code = 'USD' amount = 100 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    data(conv_curr_output_config_1) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                   target_curr_amount = 80 ).
    data(conv_curr_output_config_2) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                   target_curr_amount = 90 ).

    " configure double to return "80" for the first two invocations and return "85" from the third invocation onwards
    currency_converter->configure_call( )->when( conv_curr_input_config
                                               )->then_set_output( conv_curr_output_config_1 )->for_times( 2
                                               )->then_set_output( conv_curr_output_config_2 ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 250 act = total_expense ).
  endmethod.

  method non_configured_parameters.
    " How input parameters are handled if it is not configured by the user with test data?

    " Any input parameter of a function module which is not configured in the input configuration would be
    " implicitly considered as a parameter to be ignored while test execution.
    " Meaning, any value would be accepted for such missing parameters during function call.

    " This behavior is applicable to all input parameters including mandatory parameters, optional parameters and parameters with default values.

    " add expenses
    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'INR' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'GBP' amount = 100 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " parameter "SOURCE_CURRENCY" is not configured with a test data. so it is ignored and any value would be accepted.
    data(conv_curr_input_config) = currency_converter->create_input_configuration( )->set_importing_parameter( name = 'AMOUNT' value = 100
                                                                                   )->set_importing_parameter( name = 'TARGET_CURRENCY' value = 'EUR' ).
    data(conv_curr_output_config) = currency_converter->create_output_configuration( )->set_exporting_parameter( name = 'TARGET_CURR_AMOUNT' value = 80 ).

    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 240 act = total_expense ).
  endmethod.

  method last_configuration_behavior.

    " Last configuration done on a test double for an input will always have more importance than any previous configurations on the same input.

    " Last configuration for an input would be repeated for any further function invocations if not explicitly limited using "for_times()".
    " If last configuration is explicitly limited using "for_times()" the test double would revert to default behavior defined in test method "default_behavior()"

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 100 ).

    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    data(conv_curr_output_config) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                 target_curr_amount = 80 ).

    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    " output "80" would be returned for any further function calls on input "100, USD, EUR"
    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 160 act = total_expense ).



    " now let's add another output for the same input set
    conv_curr_output_config = get_conv_curr_output_config( currency_converter = currency_converter
                                                           target_curr_amount = 90 ).

    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    " the new output "90" would be returned on further function calls,
    " as the last configuration would override any previous configurations done on the same input.
    total_expense = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 180 act = total_expense ).
  endmethod.

  method raise_classic_exception.
    " How to raise a classic exception as output on function invocation.

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    " configure double
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_raise_classic_exception( 'no_rate_found' ).

    try.
      data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
      cl_abap_unit_assert=>fail( 'Exception cx_ftd_currency_conv_error not raised' ).
    catch cx_ftd_currency_conv_error.
      " expected exception
    endtry.
  endmethod.

  method raise_exception.

    " How to raise class based exception on function invocation.

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 200 ).

    " get test double
    data(base_curr_converter) = function_test_environment->get_double( 'FTD_CONVERT_TO_BASE_CURRENCY' ).

    " test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_to_base_curr_i_config( base_curr_converter = base_curr_converter
                                                                   amount = 100 source_currency = 'USD' ).

    " configure double
    base_curr_converter->configure_call( )->when( conv_curr_input_config )->then_raise_exception( new cx_ftd_currency_conv_error( ) ).

    try.
      data(total_expense) = expense_manager->calc_totalexpense_in_base_curr( ).
      cl_abap_unit_assert=>fail( 'Exception cx_ftd_currency_conv_error not raised' ).
    catch cx_ftd_currency_conv_error.
    endtry.
  endmethod.

  method behavior_verification.

    " Verification of test double behavior.
    " We could verify at the end of a test whether the test double we have configured has behaved as per the configurations.

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'USD' amount = 200 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration - for amount 100
    data(conv_curr_input_config_1) = get_conv_curr_input_config( currency_converter = currency_converter
                                                                 amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    data(conv_curr_output_config) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                 target_curr_amount = 80 ).

    " configure double
    currency_converter->configure_call( )->when( conv_curr_input_config_1 )->then_set_output( conv_curr_output_config ).

    " test data configuration - for amount 200
    data(conv_curr_input_config_2) = get_conv_curr_input_config( currency_converter = currency_converter
                                                                 amount = 200 source_currency = 'USD' target_currency = 'EUR' ).

    conv_curr_output_config = get_conv_curr_output_config( currency_converter = currency_converter
                                                           target_curr_amount = 160 ).

    " configure double
    currency_converter->configure_call( )->when( conv_curr_input_config_2 )->then_set_output( conv_curr_output_config ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 240 act = total_expense ).

    " verify test double interaction behavior

    " verify how many times the test double has been invoked for any input configurations
    currency_converter->verify( )->is_called_times( 2 ).

    "verify test double for a specific input configuration
    currency_converter->verify( conv_curr_input_config_1 )->is_called_once( ).
    currency_converter->verify( conv_curr_input_config_2 )->is_called_once( ).
  endmethod.

  method ignore_all_parameters.

    " What if we do not bother about the input, but need to return some output on function call.
    " One option would be to create a dummy input configuration and configure the test double using when() and then(), also

    " Another easy option would be to make use of the api "ignore_all_parameters()" as explained below.

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'INR' amount = 200 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration
    data(conv_curr_output_config) = currency_converter->create_output_configuration( )->set_exporting_parameter( name = 'TARGET_CURR_AMOUNT' value = 80 ).

    " configure double to return "80" for any input
    currency_converter->configure_call( )->ignore_all_parameters( )->then_set_output( conv_curr_output_config ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 160 act = total_expense ).
  endmethod.

  method argument_matcher.
    " Explains the usage of argument matchers for accepting a range of values in input

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).
    expense_manager->add_expense( description = 'Expense 2' currency_code = 'INR' amount = 100 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration

    " "SOURCE_CURRENCY" is configured using the argument matcher cl_ftd_argument_matcher=>covers_pattern( ),
    " which would accept only the values of SOURCE_CURRENCY which contains the given pattern.

    " Additional argument matchers could be accessed via the class cl_ftd_argument_matcher as per need.
    data(conv_curr_input_config) = currency_converter->create_input_configuration( )->set_importing_parameter( name = 'AMOUNT' value = 100
                                                                                   )->set_importing_parameter( name = 'SOURCE_CURRENCY' value = cl_ftd_argument_matcher=>covers_pattern( 'U*' )
                                                                                   )->set_importing_parameter( name = 'TARGET_CURRENCY' value = 'EUR' ).

    data(conv_curr_output_config) = currency_converter->create_output_configuration( )->set_exporting_parameter( name = 'TARGET_CURR_AMOUNT' value = 80 ).

    " configure double
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 80 act = total_expense ).
  endmethod.

  method custom_answer.
    " Sometimes if the apis given from the framework is not enough to define the behavior of a function for a specific input,
    " it is possible to provide custom answers. Define your answer implementation using the interface "if_ftd_invocation_answer"
    " and provide an instance to the implementation as answer during configuration.

    expense_manager->add_expense( description = 'Expense 1' currency_code = 'INR' amount = 100 ).

    " get test double
    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'INR' target_currency = 'EUR' ).

    " configure double with a custom answer
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_answer( new lcl_my_answer( ) ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 10 act = total_expense ).
  endmethod.

  method disable_testdouble.
    " If there is a scenario which requires execution of the actual function module in the test session, it would be possible to either selectively disable an individual test double
    " or disable all the test doubles in the test session.

    " To disable an individual test double,
    " - Get the test double instance using: data(function_double) = function_test_environment->get_double( { function_module_name } ).
    " - Call the API disable on the function test double: function_double->disable( ).

    " To disable all the test doubles in the test session all at once,
    " - Call the API disable_doubles at the function environment instance: function_test_environment->disable_doubles( ).

    " Please note that, this is a global action, which means disabling test doubles would be applied to all the test methods of the test even if it is being executed in an individual test method.

    " It is possible to re-enable the disbaled test doubles by using,
    " - function_double->enable( ) " to activate a disabled function double
    " - function_test_environment->enable_doubles( ) " to activate all the test doubles in the test session once disabled.

    " Example
    expense_manager->add_expense( description = 'Expense 1' currency_code = 'USD' amount = 100 ).


    " Configure function module 'FTD_CONVERT_CURRENCY'

    data(currency_converter) = function_test_environment->get_double( 'FTD_CONVERT_CURRENCY' ).

    " input test data configuration - for amount 100
    data(conv_curr_input_config) = get_conv_curr_input_config( currency_converter = currency_converter
                                                               amount = 100 source_currency = 'USD' target_currency = 'EUR' ).

    " output test data configuration
    data(conv_curr_output_config) = get_conv_curr_output_config( currency_converter = currency_converter
                                                                 target_curr_amount = 80 ).

    " configure
    currency_converter->configure_call( )->when( conv_curr_input_config )->then_set_output( conv_curr_output_config ).

    data(total_expense) = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 80 act = total_expense ).

    " Now disable the function module
    currency_converter->disable( ).

    " While executing the code under test again, the actual function module is invoked. Hence 80 is not returned.
    total_expense = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = total_expense ).

    " Enable the test double back
    currency_converter->enable( ).

    " Now the test double would get invoked on code under test execution instead of the actual function module and we should get the configured test data.
    total_expense = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 80 act = total_expense ).

    " Note: The statement currency_converter->disable( ). would only disable the test double for 'FTD_CONVERT_CURRENCY'
    " and not the test double for 'FTD_CONVERT_TO_BASE_CURRENCY' which is also part of the test environment.
    " To disable both use,
    function_test_environment->disable_doubles( ).

    " All the function doubles are now disabled in the test session.
    total_expense = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = total_expense ).

    " To enable all the test doubles again,
    function_test_environment->enable_doubles( ).

    " The test double should be enabled back again now
    total_expense = expense_manager->calculate_total_expense( 'EUR' ).
    cl_abap_unit_assert=>assert_equals( exp = 80 act = total_expense ).
  endmethod.



  method get_conv_curr_input_config.
    result = currency_converter->create_input_configuration( )->set_importing_parameter( name = 'AMOUNT' value = amount
                                                             )->set_importing_parameter( name = 'SOURCE_CURRENCY' value = source_currency
                                                             )->set_importing_parameter( name = 'TARGET_CURRENCY' value = target_currency ).
  endmethod.

  method get_conv_curr_output_config.
    result = currency_converter->create_output_configuration( )->set_exporting_parameter( name = 'TARGET_CURR_AMOUNT' value = target_curr_amount ).
  endmethod.

  method get_conv_to_base_curr_i_config.
    result = base_curr_converter->create_input_configuration( )->set_importing_parameter( name = 'AMOUNT' value = amount
                                                              )->set_importing_parameter( name = 'SOURCE_CURRENCY' value = source_currency ).
  endmethod.

  method get_conv_to_base_curr_o_config.
    result = base_curr_converter->create_output_configuration( )->set_exporting_parameter( name = 'BASE_CURR_AMOUNT' value = base_curr_amount ).
  endmethod.

endclass.