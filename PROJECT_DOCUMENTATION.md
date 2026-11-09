# Study Armenia LK - Project Documentation

## Overview

Study Armenia LK is an Android-first Flutter application for Sri Lankan students who want to study in Armenia. It combines university discovery, application intake, student and parent tracking, communication, and administration.

- App version: `1.0.0+1`
- Android package: `com.armenia.lanka.edu`
- Flutter/Dart with Firebase Authentication, Firestore, Storage, Messaging, and Cloud Functions
- Minimum Android version: Android 6.0 (API 23)

## Roles

### Student

- Registers with email, phone, and password.
- Browses and searches universities.
- Submits or updates one application tied to the Firebase UID.
- Uploads passport, result sheets, and a photograph.
- Views application status, progress, fees, meetings, notices, and news.
- Shares the full Student ID shown in Settings with a parent or guardian.

### Parent or guardian

- Registers as a parent and enters the student's full Student ID.
- The link starts as pending and does not grant data access.
- An administrator verifies and approves the link in Admin > Parent Links.
- After approval, the parent can read that student's application, progress, and fee records.

### Administrator

- An admin is a Firebase user whose `users/{uid}.role` is `admin`.
- Admin access is never granted from a hardcoded email address.
- Admins manage applications, announcements, media, notifications, progress, fees, meetings, news, and parent links.

The first administrator must be promoted manually in the Firebase console or with a trusted Admin SDK script. Never allow a mobile client to promote itself.

## Main navigation

1. Home: campaigns, quick links, announcements, featured universities, and the notification inbox.
2. Universities: category filters, full-text search, fees, programs, benefits, and WhatsApp inquiry.
3. Apply: personal details, program selection, document upload, review, and live status.
4. Media: real-time posts, per-user likes, copied sharing text, and external video streaming links.
5. Parent Portal: progress, fees, meetings, notices, news, and counselor contact.
6. Settings: profile, Student ID, password, persistent theme/notification/email preferences, privacy policy, support, and store rating.
7. Admin: displayed only when the authenticated Firestore user role is `admin`.

## Project layout

```text
lib/
  core/
    constants/
    firebase/
    theme/
  models/
  screens/
    admin/
    apply/
    auth/
    home/
    media/
    notifications/
    parent_portal/
    settings/
    splash/
    universities/
  services/
functions/
firestore.rules
storage.rules
firebase.json
```

## Firebase collections

| Collection | Document key | Purpose |
|---|---|---|
| `users` | Auth UID | Profile, role, parent link, preferences |
| `applications` | Student UID | Application and document references |
| `document_files` | Generated from UID/type | Small Base64 fallback when Storage is unavailable |
| `announcements` | Auto ID | Home and parent notices |
| `media_posts` | Auto ID | Media feed; `likes/{uid}` stores individual likes |
| `student_progress` | Student UID | Semester, GPA, attendance, and subjects |
| `student_fees` | Student UID | Fee items and payment status |
| `meetings` | Auto ID | Parent meeting schedule and Meet links |
| `news_articles` | Auto ID | Parent news |
| `notifications` | Auto ID | In-app inbox and FCM push source |
| `users/{uid}/notification_reads` | Notification ID | Per-user read state |

Documents normally upload to:

```text
applications/{studentUid}/{documentType}/{fileName}
```

Storage uploads are limited to 10 MB by `storage.rules`. When Storage is unavailable, non-PDF images are compressed and files smaller than approximately 900 KB can use the Firestore fallback.

## Security model

The repository includes deny-by-default Firestore and Storage rules.

- Public app data requires authentication.
- Students can read their own private records.
- Approved parents can read only their linked student's private records.
- Only admins can write progress, fees, meetings, news, announcements, notifications, and media posts.
- Students cannot change their own role, parent link, link approval, or application status.
- Admin privileges are checked both in the UI and Firebase rules.

Deploy rules with:

```bash
firebase deploy --only firestore:rules,storage
```

Rules must be deployed before using the production app. Client-side checks alone are not security controls.

## Push notifications

The Android client subscribes to the FCM topic `all_users` when push notifications are enabled. Creating a Firestore notification triggers `functions/sendNotification`, which sends the FCM message. Foreground messages appear in the app; background messages use Android notification delivery. Every notification also remains available in the in-app inbox.

Deployment prerequisites:

- Install Firebase CLI and sign in.
- Use Node.js 22 for the Functions runtime.
- Select the correct Firebase project.
- The Firebase project must support Cloud Functions deployment.

```bash
cd functions
npm install
cd ..
firebase deploy --only functions:sendNotification
```

## Media videos

The large `.mov` files in `vedio/medicine/` are intentionally not bundled. Upload production videos to YouTube, Firebase Storage, or another streaming host, then paste the HTTPS video URL into Admin > Manage Media. The app launches that streaming URL from the media post.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

The current Firebase options support Android only. iOS, web, Windows, macOS, and Linux require their own Firebase app registrations and regenerated FlutterFire options before they can run.

## Android release signing

Release builds no longer use the debug key. Generate an upload keystore, copy `android/key.properties.example` to `android/key.properties`, and fill in the real values. Both `key.properties` and keystore files are ignored by Git.

```bash
flutter build apk --release --target-platform android-arm64
```

If no release keystore is configured, Gradle can produce an unsigned release artifact; do not distribute it.

## Production checklist

- Deploy Firestore and Storage rules.
- Set the first administrator's Firestore role using a trusted environment.
- Deploy the notification Cloud Function.
- Configure the Android release keystore.
- Verify university claims, fees, rankings, accreditations, contact numbers, and policy wording with the business owner.
- Replace generic or expired meeting links through the admin panel.
- Upload videos to a streaming provider and attach URLs to media posts.
- Add the final Play Store listing before enabling the Rate App link in production.
- Run `flutter analyze`, `flutter test`, and a physical-device acceptance test.
