# Study Armenia LK

Flutter/Firebase application for Sri Lankan students applying to universities in Armenia, their linked parents or guardians, and consultancy administrators.

## Local setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Firebase configuration is already present for Android. Before production, deploy the included Firestore/Storage rules and notification function, create an administrator role in a trusted environment, and configure Android release signing.

See [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md) for architecture, roles, Firebase schema, security, push notification deployment, and release instructions.
