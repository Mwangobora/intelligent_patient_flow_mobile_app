# Patient API Coverage

This document tracks Flutter patient-mobile API usage against backend Swagger.
Only patient-owned or patient-safe flows are consumed in the mobile app.

| Endpoint | Feature/screen | Action | Patient-safe | Implemented | Notes |
| --- | --- | --- | --- | --- | --- |
| `POST /api/v1/auth/login/` | Login | Sign in | Yes | Yes | Cookie session is persisted through secure cookie storage. |
| `POST /api/v1/auth/logout/` | Profile/Home | Logout | Yes | Yes | Clears backend cookies and local cookie jar. |
| `GET /api/v1/auth/me/` | Splash/session | Session check | Yes | Yes | Used for startup auth guard. |
| `PATCH /api/v1/auth/me/` | Profile | Update safe user names | Yes | Yes | Does not expose staff flags or passwords. |
| `POST /api/v1/auth/change-password/` | Profile | Change password | Yes | Yes | Uses `old_password` and `new_password`. |
| `POST /api/v1/auth/refresh/` | Session | Refresh cookie | Yes | No | Access cookie lifetime is long enough for local mobile testing. |
| `GET /api/v1/patients/` | Profile/Home | Find linked patient profile | Partial | Yes | Filtered by current user id; a dedicated `/patient/profile/` endpoint would be safer. |
| `PATCH /api/v1/patients/{id}/` | Profile | Update patient demographics | No | No | Staff-managed endpoint; mobile should get a patient-safe self-service endpoint first. |
| `GET /api/v1/patients/{id}/addresses/` | Profile | Addresses | No | No | Staff-managed and sensitive; skipped for mobile. |
| `GET /api/v1/patients/{id}/identifiers/` | Profile | Identifiers | No | No | Sensitive identifiers are skipped. |
| `GET /api/v1/scheduling/appointments/` | Appointments/Home | List own appointments | Partial | Yes | Filtered by patient id from linked profile. |
| `POST /api/v1/scheduling/appointments/` | Booking | Create appointment | Partial | Yes | Requires booking lookup endpoints that are currently permission-protected. |
| `GET /api/v1/scheduling/appointments/{id}/` | Appointment detail | Detail | Partial | Yes | Opened from own appointment list. |
| `POST /api/v1/scheduling/appointments/{id}/cancel/` | Appointment detail | Cancel | Partial | Yes | Shows confirmation and reason. |
| `POST /api/v1/scheduling/appointments/{id}/reschedule/` | Appointment booking | Reschedule | Partial | Yes | Uses same slot flow when lookups are available. |
| `GET /api/v1/scheduling/appointments/{id}/status-history/` | Appointment detail | Status history | Partial | Yes | Read-only history. |
| `GET /api/v1/facilities/facilities/` | Booking | Facility lookup | No for demo patient | Attempted | Returns `403`; needs patient-safe read endpoint. |
| `GET /api/v1/facilities/facility-specialties/` | Booking | Service lookup | No for demo patient | Attempted | Returns `403`; needs patient-safe read endpoint. |
| `GET /api/v1/scheduling/slots/` | Booking | Available slots | No for demo patient | Attempted | Returns `403`; needs patient-safe read endpoint. |
| `GET /api/v1/practitioners/` | Booking | Practitioner lookup | No | No | Staff-managed endpoint; skipped. |
| `GET /api/v1/patient/checkins/eligibility/` | Check-in | Eligibility | Yes | Yes | Dedicated patient-safe endpoint. |
| `POST /api/v1/patient/checkins/appointments/{appointment_id}/check-in/` | Check-in | Mobile check-in | Yes | Yes | Dedicated patient-safe endpoint. |
| `POST /api/v1/patient/checkins/appointments/{appointment_id}/qr-token/` | Check-in | Show QR | Yes | Yes | Raw token is displayed as QR only and not logged. |
| `POST /api/v1/patient/checkins/qr/consume/` | QR scanner | Consume scanned QR | Yes | Yes | Dedicated patient-safe endpoint. |
| `GET /api/v1/patient/queue/current/` | Queue | Current queue | Yes | Yes | Dedicated patient-safe endpoint. |
| `GET /api/v1/patient/queue/history/` | Queue | Queue history | Yes | Yes | Dedicated patient-safe endpoint. |
| `GET /api/v1/notifications/` | Notifications | List own notifications | Partial | Yes | Uses `patient_id`; a `/patient/notifications/` endpoint would be safer. |
| `GET /api/v1/notifications/{id}/` | Notifications | Detail | Partial | Yes | Opened only from own list; backend should enforce ownership. |
| `POST /api/v1/notifications/{id}/mark-read/` | Notifications | Mark read | Partial | Yes | Used only for own list/detail items. |
| `POST /api/v1/notifications/{id}/cancel/` | Notifications | Cancel | No | No | Staff/system action; skipped. |
| `POST /api/v1/notifications/{id}/send/` | Notifications | Send | No | No | Staff/system action; skipped. |
| `GET /api/v1/notifications/push-devices/` | Notifications | List devices | Partial | Service only | Requires `notifications_device.view`; no device-token provider configured yet. |
| `POST /api/v1/notifications/push-devices/` | Notifications | Register device | Partial | Service only | Requires real push token from FCM/APNs/web push. |
| `POST /api/v1/notifications/push-devices/{id}/last-seen/` | Notifications | Device ping | Partial | Service only | No token provider configured yet. |
| `POST /api/v1/notifications/push-devices/{id}/revoke/` | Notifications | Revoke device | Partial | Service only | No token provider configured yet. |
| `POST /api/v1/notifications/push-devices/{id}/deactivate/` | Notifications | Deactivate device | Partial | Service only | No token provider configured yet. |

## Backend Gaps For Full Patient Mobile

- Add patient-safe booking lookup endpoints for facilities, services/specialties, and available slots.
- Add a patient-owned profile endpoint such as `GET/PATCH /api/v1/patient/profile/`.
- Add patient-owned notifications endpoints such as `GET /api/v1/patient/notifications/`.
- Add push-token provider integration before enabling automatic device registration.
