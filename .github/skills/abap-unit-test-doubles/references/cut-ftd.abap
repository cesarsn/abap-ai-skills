class cl_ftd_expense_manager definition public final create public for testing.

  public section.

    methods add_expense
      importing
        description   type string
        currency_code type string
        amount        type i.

    methods clear_expenses.

    methods calculate_total_expense
      importing
        currency_code type string
      returning
        value(result) type i
      raising
        cx_ftd_currency_conv_error.

    methods calc_totalexpense_in_base_curr
      returning
        value(result) type i
      raising
        cx_ftd_currency_conv_error.

  protected section.

  private section.

    types:
      begin of ty_expense,
        description   type string,
        currency_code type string,
        amount        type i,
      end of ty_expense.
    types tt_expense type standard table of ty_expense.

    data: expenses type tt_expense.
ENDCLASS.



CLASS CL_FTD_EXPENSE_MANAGER IMPLEMENTATION.


  method add_expense.
    data(expense) = value ty_expense( amount = amount currency_code = currency_code description = description ).
    append expense to expenses.
  endmethod.


  method calculate_total_expense.
    data convterted_amount type i.

    loop at expenses into data(expense).

      clear convterted_amount.

      call function 'FTD_CONVERT_CURRENCY'
        exporting
          amount             = expense-amount
          source_currency    = expense-currency_code
          target_currency    = currency_code
        importing
          target_curr_amount = convterted_amount
        exceptions
          no_rate_found      = 1
          conversion_error   = 2
          others             = 3.
      if sy-subrc <> 0.
        raise exception new cx_ftd_currency_conv_error( ).
      endif.

      result = result + convterted_amount.

    endloop.
  endmethod.


  method calc_totalexpense_in_base_curr.
    data convterted_amount type i.
    data base_currency type string.

    base_currency = 'EUR'.

    loop at expenses into data(expense).

      clear convterted_amount.

      call function 'FTD_CONVERT_TO_BASE_CURRENCY'
        exporting
          amount           = expense-amount
          source_currency  = expense-currency_code
        importing
          base_currency    = base_currency
          base_curr_amount = convterted_amount.

      result = result + convterted_amount.

    endloop.
  endmethod.


  method clear_expenses.
    clear expenses.
  endmethod.
ENDCLASS.