# Backend notification integration

This project uses Firebase Cloud Messaging on the Flutter client and expects
the backend to handle notification sending through the FCM HTTP v1 API.

## Client-to-backend token sync

Endpoint:

```text
POST /api/v1/notifications/fcm-token
```

Headers:

```http
Authorization: Bearer USER_ACCESS_TOKEN
Content-Type: application/json
Accept: application/json
```

Request body:

```json
{
  "fcm_token": "DEVICE_FCM_TOKEN",
  "platform": "android"
}
```

Behavior:

- Authenticate the user from the bearer token.
- Store or update the latest FCM token for that user.
- If a user can log in on multiple devices, store multiple active tokens.
- Remove invalid or expired tokens when FCM returns token errors.

Success response example:

```json
{
  "success": true,
  "message": "FCM token saved"
}
```

## Server-side notification sender

Your backend should keep the Firebase service account JSON on the server only
and call the FCM HTTP v1 API from there.

FCM endpoint:

```text
POST https://fcm.googleapis.com/v1/projects/ciac-school/messages:send
```

Headers:

```http
Authorization: Bearer GOOGLE_OAUTH_ACCESS_TOKEN
Content-Type: application/json
```

Payload example:

```json
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "New Homework",
      "body": "Math exercises were added."
    },
    "data": {
      "type": "homework",
      "category": "homework"
    },
    "android": {
      "priority": "HIGH",
      "notification": {
        "sound": "homework_notification"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "homework_notification.wav"
        }
      }
    }
  }
}
```

## Suggested backend endpoint for admins

Endpoint:

```text
POST /api/v1/notifications/send
```

Suggested request body:

```json
{
  "user_id": 123,
  "title": "New Homework",
  "body": "Math exercises were added.",
  "data": {
    "type": "homework",
    "category": "homework"
  }
}
```

Suggested backend behavior:

1. Validate that the caller is allowed to send notifications.
2. Look up one or more FCM tokens for the target user.
3. Send one FCM HTTP v1 request per token, or use topics if that matches your
   backend design.
4. Delete tokens that fail with invalid-registration or unregistered errors.
5. Return a small send summary to the caller.

## Notes

- The Flutter app now re-syncs the token when Firebase rotates it.
- If the token sync endpoint is not ready yet, the app will continue working
  and only log the sync failure.
- Keep all Firebase service account credentials on the backend, never in the
  mobile app.
