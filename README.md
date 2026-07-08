# CIAC App

CIAC App is a Flutter school application for parent and teacher users. The app
supports role-based access, student information, attendance workflows, homework,
class activities, payments, notifications, and school contact tools.

## Features

### Parent (V1)

1. Login with parent credentials and access a parent-specific dashboard.
2. Select and view linked child profiles.
3. View student information, class details, and student documents.
4. Track student attendance, attendance summaries, and attendance history.
5. View class schedule and standings.
6. View assigned homework by class.
7. Submit completed student homework.
8. Browse class activities and activity details.
9. Request student leave and review submitted leave requests.
10. View payment history and invoice details.
11. Receive push notifications for school updates and homework changes.
12. View announcements, dashboard banners, and school contact information.
13. Update profile information, change password, switch language, and review
  terms and conditions.

### Teacher(V1)

1. Login with teacher credentials and access a teacher-specific dashboard.
2. View teacher dashboard statistics.
3. Scan QR codes to record attendance.
4. Review attendance scan records.
5. View class schedules and standings.
6. Create, update, list, and delete homework assignments.
7. Attach homework files and review homework submission status.
8. Mark or submit homework status for students.
9. Create, update, list, and delete class activities.
10. Upload activity images and view activity details.
11. Receive push notifications for relevant school updates.
12. View announcements, dashboard banners, and school contact information.
13. Update profile information, change password, switch language, and review
  terms and conditions.

### Teacher(V2)

14. View student attendance records by (class, section, subject, date).
15. Record student attendance by (class, section, subject, date).
16. View leave requests by date.


## Push Notifications

This app collects the device `fcm_token` during login and syncs refreshed
Firebase tokens to the backend automatically.

Use your existing backend to send notifications. Do not send FCM requests
directly from Flutter and do not put a Firebase service account inside the app.

Backend endpoint expected by the app:

- `POST /api/v1/notifications/fcm-token`
- Header: `Authorization: Bearer <user_token>`
- Body:

```json
{
  "fcm_token": "DEVICE_FCM_TOKEN",
  "platform": "android"
}
```

Recommended notification sending flow:

1. App logs in and sends `fcm_token` to your backend.
2. Backend stores the token for that user.
3. Admin panel or backend logic calls FCM HTTP v1 using the Firebase service
   account on the server.
4. Firebase delivers the push notification to the device.

Full backend contract and sample payloads are in
[docs/backend-notifications.md](docs/backend-notifications.md).

## Development

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Analyze the project:

```bash
flutter analyze
```