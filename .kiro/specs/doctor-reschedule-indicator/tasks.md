# Implementation Plan

- [~] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - Missing Reschedule Indicator on Doctor Side
  - **CRITICAL**: This test MUST FAIL on unfixed code — failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior — it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the missing reschedule indicator
  - **Scoped PBT Approach**: Scope the property to the concrete failing case — any request where `req.status = 'edited'`
  - For the web template: parse the rendered HTML of the `edited` loop and assert it contains a `bi-clock-history` icon element and a "RESCHEDULED" label
  - For the Flutter screen: inspect the widget tree of `_buildPendingCard` for a rescheduled request and assert it contains a reschedule indicator widget (clock icon + "RESCHEDULED" text)
  - Bug condition: `isBugCondition(req)` where `req.status = 'edited'`
  - Expected behavior: `doctorWebCard CONTAINS reschedule_indicator` AND `doctorFlutterCard CONTAINS reschedule_indicator`
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct — it proves the bug exists)
  - Document counterexamples found (e.g., "edited card HTML contains no `bi-clock-history` icon", "Flutter pending card has no reschedule row for rescheduled request")
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2_

- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Rescheduled Cards Are Unaffected
  - **IMPORTANT**: Follow observation-first methodology
  - Observe: on unfixed code, a `pending` request card in `requests_pending.html` renders with `<span class="status-pill pending">PENDING</span>` and no clock icon
  - Observe: on unfixed code, a `pending` Flutter card renders with `statusLabel: 'PENDING'` and no reschedule row
  - Observe: accepted and done cards are rendered by separate templates/widgets and are unaffected by changes to the pending view
  - Write property-based test: for all requests where `NOT isBugCondition(req)` (i.e., `status != 'edited'`), the rendered doctor card is identical before and after the fix — no reschedule indicator is added, no existing badge is removed
  - Covers: plain pending cards (web + Flutter), accepted cards, done cards, and the patient-side template (must remain unchanged)
  - Verify tests PASS on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 3. Fix missing reschedule indicator on doctor side

  - [ ] 3.1 Fix web template — add reschedule indicator to `edited` cards in `requests_pending.html`
    - In `doctor/templates/doctor/requests_pending.html`, locate the `{% for p in edited %}` loop
    - Replace the plain amber `<span class="status-pill" style="background:#fff3cd; color:#856404;">EDITED</span>` badge in the `card-top-section` with a reschedule indicator block matching the patient side: `<i class="bi bi-clock-history"></i>` icon + `"RESCHEDULED"` label
    - The indicator should use the same visual style as the patient-side reschedule badge (amber/clock-history icon) so both sides are consistent
    - Do NOT modify the `{% for p in pending %}` loop, the form submission logic, or any other section of the template
    - _Bug_Condition: `isBugCondition(req)` where `req.status = 'edited'`_
    - _Expected_Behavior: `doctorWebCard CONTAINS reschedule_indicator` (bi-clock-history icon + "RESCHEDULED" label)_
    - _Preservation: pending cards keep their existing "PENDING" badge; form actions (reject/reschedule) are unchanged_
    - _Requirements: 2.1, 3.1, 3.2_

  - [ ] 3.2 Fix Flutter screen — add reschedule indicator to rescheduled pending cards in `doctor_requests_screen.dart`
    - In `flutter_section/lib/Doctor/doctor_requests_screen.dart`, update the `ConsultationRequest` model or the pending list filter to distinguish rescheduled requests (e.g., add an `isRescheduled` flag or check a `rescheduled` status value)
    - In `_buildPendingCard`, after the `_CardTopRow`, add a conditional reschedule indicator row: when the request is rescheduled, render a row with a clock-history icon (`Icons.history` or equivalent) and a "RESCHEDULED" label in amber, matching the visual language of the web template
    - Do NOT modify `_buildAcceptedCard`, `_buildDoneCard`, or any non-pending card builder
    - Do NOT change the accept/reject action callbacks or the time-slot carousel logic
    - _Bug_Condition: `isBugCondition(req)` where `req.status = 'edited'` (rescheduled)_
    - _Expected_Behavior: `doctorFlutterCard CONTAINS reschedule_indicator` (clock icon + "RESCHEDULED" text)_
    - _Preservation: plain pending cards (non-rescheduled) show no reschedule indicator; accepted and done cards are unchanged_
    - _Requirements: 2.2, 3.1, 3.2_

  - [ ] 3.3 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Reschedule Indicator Present on Doctor Side
    - **IMPORTANT**: Re-run the SAME test from task 1 — do NOT write a new test
    - The test from task 1 encodes the expected behavior
    - When this test passes, it confirms the reschedule indicator is now rendered for `edited` requests on both the web template and the Flutter screen
    - Run bug condition exploration test from step 1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - _Requirements: 2.1, 2.2_

  - [ ] 3.4 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Rescheduled Cards Are Unaffected
    - **IMPORTANT**: Re-run the SAME tests from task 2 — do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Confirm plain pending cards, accepted cards, done cards, and the patient-side template are all unchanged after the fix
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 4. Checkpoint — Ensure all tests pass
  - Ensure all tests pass; ask the user if any questions arise
  - Confirm the web template `edited` loop renders the `bi-clock-history` icon and "RESCHEDULED" label
  - Confirm the Flutter pending card shows the reschedule indicator for rescheduled requests
  - Confirm no regressions on plain pending, accepted, done, or patient-side views
