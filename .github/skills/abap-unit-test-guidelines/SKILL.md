---
name: abap-unit-test-guidelines
description: This document defines the guidelines for writing ABAP Unit Tests in the project. Use it when you want to create a new ABAP Unit Test or improve an existing one.
---

# ABAP Unit Test Guidelines

## Overview

This skills helps me to write ABAP Unit Tests in a consistent way across the project. It provides guidelines for writing unit tests, including naming conventions, test structure, and best practices.

## Instructions

### Rule 1: Naming conventions
* **Rule:** 
	* Use LTC_<class test name> for local test classes.
	* Use LTD_<class test double name> for local test doubles classes
	* Use LTH_<class test helper class> for local test helper classes

### Rule 2: Avoid Magic Numbers and Strings in Unit Tests
* **Rule:** You are creating auxiliary variables in your unit test for representing test data. Give to these variables meaningful names. For example, you are creating a variable for a test customer and the customer code is not relevant and any can be used, name variable as CV_ANY_CUSTOMER or LV_ANY_CUSTOMER (CV_ is used for constants and LV_ for local variables).Other example can be CV_ANY_OTHER_CUSTOMER if two customers are required for the process.

### Rule 3: Consider the maximum length of test method names
* **Rule:** test method names should have at most 30 characters. Include a comment in method definition previous to method name with a summary of the test intent. Example:
    "Test creation of a travel with no bookings or supplements
    METHODS tc_create_100_ok FOR TESTING.

### Rule 4: Activate objects before executing unit tests
* **Rule:** Before executing unit test always activate CUT and test include.


