---
name: abap-unit-test-skill-test-double
description: This document defines how to use Test doubles for ABAP Unit testing when code under test (CUT) has external dependencies (Database or function modules).
---

# ABAP Test Double Framework Use

## Overview

This skills helps me to create proper test doubles using standard test double framework when CUT has database of function module dependencies

## Instructions

### Case 1: Open SQL Test Double Framework (OSQL)
**Trigger:** If CUT uses database operations (`SELECT`, `INSERT`, `UPDATE`, `MODIFY`, `DELETE`).

#### Generation instructions:
1. **Mandatory reference:** Use as technical blueprint reference file 'OSQL_TEST_DEMO.ABAP'. Ask to be added to the context if you do not have access.

---

### Case 2:Function Test Double Framework (FTD)
**Trigger:** If CUT uses sentence `CALL FUNCTION`.

#### Generation instructions:
1. **Mandatory reference:** Use as technical blueprint reference file 'FTD_TEST_DEMO.ABAP'. Ask to be added to the context if you do not have access.
