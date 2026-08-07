---
name: abap-unit-test-guidelines
description: This document defines the guidelines for writing ABAP Unit Tests in the project. Use it when you want to create a new ABAP Unit Test or improve an existing one.
---

# ABAP Unit Test Guidelines

## Overview

This skills helps me to write ABAP Unit Tests in a consistent way across the project. It provides guidelines for writing unit tests, including naming conventions, test structure, and best practices.

## Instructions

### Rule 1: Avoid Magic Numbers and Strings in Unit Tests
* **Rule:** You are creating auxiliary variables in your unit test for representing test data. For example, you are creating a variable for a test customer. Name this constants/variables as CV_ANY_CUSTOMER or LV_ANY_CUSTOMER. The prefix CV_ is used for constants and LV_ for local variables. The ANY keyword is used to indicate that this variable can represent any customer, not a specific one.

### Rule 2: Consider the maximum length of test method names
* **Rule:** test method names should have at most 30 characters. Include a comment in method definition previous to method name with a summary of the test intent. Example:
    "Test creation of a travel with no bookings or supplements
    METHODS tc_create_100_ok FOR TESTING.

### Rule 3: Activate objects before executing unit tests
* **Rule:** If you have access to a test execution and ABAP object activation tools, activate class and test include before executing the tests.


