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
* ** Generation instructions:**
1. **Mandatory reference:** Use as technical blueprint reference file 'test-osql.abap'.

### Case 2: Function Test Double Framework (FTD)
* **Trigger:** CUT executes `CALL FUNCTION`.
* ** Generation instructions:**
1. **Mandatory reference:** Use as technical blueprint reference file 'test-ftd.abap'.
