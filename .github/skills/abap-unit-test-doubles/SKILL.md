---
name: abap-unit-test-doubles
description: This document defines how to use Test doubles for ABAP Unit testing when code under test (CUT) has external dependencies (Database or function modules).
---

# ABAP Test Double Framework Use

## Overview

This skills helps me to create proper test doubles using standard test double framework when CUT has database or function module dependencies

## Instructions

### Case 1: Open SQL Test Double Framework (OSQL)
* **Trigger:** CUT performs database operations (`SELECT`, `INSERT`, `UPDATE`, `MODIFY`, `DELETE`) or queries CDS Views.
* **Key Framework APIs:**
	* Setup: `cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'table_or_cds' ) ) )`
	* Insert Mock Data: `environment->insert_test_data( it_data )`
	* Teardown: `environment->destroy( )` / Clear: `environment->clear_doubles( )`
* **Reference Files:** 
	* Example of CUT source OSQL: `CUT_OSQL.ABAP`
	* Example of ABAP Unit Test source for CUT Source OSQL: `TEST_OSQL.ABAP`

### Case 2: Function Test Double Framework (FTD)
* **Trigger:** CUT executes `CALL FUNCTION`.
* **Key Framework APIs:**
  * Setup: `cl_function_test_environment=>create( VALUE #( ( 'FM_NAME' ) ) )`
  * Double Config: `function_test_environment->get_double( 'FM_NAME' )`
  * Behavior: `configure_call( )->when( input_config )->then_set_output( output_config )`
  * Clear: `function_test_environment->clear_doubles( )`
* **Reference Files:** 
	* Example of CUT source FTD: `CUT_FTD.ABAP`
	* Example ABAP Unit Test source for CUT Source FTD: `TEST_FTD.ABAP`
