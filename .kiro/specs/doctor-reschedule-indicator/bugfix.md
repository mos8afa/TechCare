# Bugfix Requirements Document

## Introduction

When a doctor reschedules a patient's appointment (edits the time slot), the request transitions to `edited` status. On the patient's pending requests view, this rescheduled request is correctly shown with a distinct reschedule indicator (a clock-history icon and "RESCHEDULED" badge). However, on the doctor's pending requests view — both in the Django web template and the Flutter mobile screen — the same rescheduled request shows no reschedule indicator. The doctor sees either a plain "EDITED" label (web) or no visual distinction at all (Flutter), making it impossible to visually identify rescheduled requests at a glance on the doctor side.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a doctor views their pending requests in the web template (`requests_pending.html`) and a request has `status = 'edited'` THEN the system displays a plain amber "EDITED" text badge with no reschedule icon or visual indicator distinguishing it from a normal pending request

1.2 WHEN a doctor views their pending requests in the Flutter mobile app (`doctor_requests_screen.dart`) and a request has been rescheduled (status `edited`) THEN the system displays the card with no reschedule sign, icon, or badge — the card is visually identical to a regular pending request

### Expected Behavior (Correct)

2.1 WHEN a doctor views their pending requests in the web template and a request has `status = 'edited'` THEN the system SHALL display a reschedule indicator (clock-history icon and "RESCHEDULED" label) on the request card, consistent with how the patient side displays the same state

2.2 WHEN a doctor views their pending requests in the Flutter mobile app and a request has been rescheduled THEN the system SHALL display a visible reschedule indicator (icon and/or label) on the pending card so the doctor can identify rescheduled requests at a glance

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a request has `status = 'pending'` (not rescheduled) THEN the system SHALL CONTINUE TO display the standard "PENDING" badge on the doctor's web and Flutter pending request cards without any reschedule indicator

3.2 WHEN a doctor accepts or rejects a rescheduled (`edited`) request THEN the system SHALL CONTINUE TO process the action correctly (updating status to `accepted` or `rejected`) without any change to the existing form submission and action logic

3.3 WHEN a doctor views accepted or completed requests THEN the system SHALL CONTINUE TO display those cards unchanged, as the reschedule indicator only applies to the pending requests view

3.4 WHEN the patient views their pending requests THEN the system SHALL CONTINUE TO display the existing reschedule indicator (`bi-clock-history` icon + "RESCHEDULED" badge) on edited requests, with no changes to the patient-side template

---

## Bug Condition Pseudocode

**Bug Condition Function** — identifies requests that trigger the missing indicator:

```pascal
FUNCTION isBugCondition(req)
  INPUT: req of type DoctorRequest
  OUTPUT: boolean

  RETURN req.status = 'edited'
END FUNCTION
```

**Property: Fix Checking** — correct behavior for rescheduled requests on the doctor side:

```pascal
FOR ALL req WHERE isBugCondition(req) DO
  doctorWebCard  ← renderDoctorPendingCard'(req)
  doctorFlutterCard ← renderDoctorFlutterCard'(req)
  ASSERT doctorWebCard CONTAINS reschedule_indicator
  ASSERT doctorFlutterCard CONTAINS reschedule_indicator
END FOR
```

**Property: Preservation Checking** — non-rescheduled requests are unaffected:

```pascal
FOR ALL req WHERE NOT isBugCondition(req) DO
  ASSERT renderDoctorPendingCard(req) = renderDoctorPendingCard'(req)
END FOR
```
