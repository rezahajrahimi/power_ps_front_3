Steps to sign the Android app (release):

1. Put your keystore file under `android/app/` and name it e.g. `keystore.jks`.

2. Copy the template and create `android/key.properties`:

```
cp android/key.properties.template android/key.properties
```

Then open `android/key.properties` and replace the values with your keystore data (storePassword, keyPassword, keyAlias, storeFile).

For example:
```
storePassword=superSecretStorePass
keyPassword=superSecretKeyPass
keyAlias=powerps_key
storeFile=android/app/keystore.jks
```

3. Ensure `key.properties` is in `.gitignore` (it is already ignored) so you don't commit secrets.

4. Build a signed APK or App Bundle:

- APK: `flutter build apk --release`
- App Bundle (recommended for Play Store): `flutter build appbundle --release`

5. The resulting file will be in `build/app/outputs/flutter-apk/app-release.apk` or `build/app/outputs/bundle/release/app-release.aab`.

Note: If `key.properties` is not present, the project will fall back to using debug signing to allow local testing. Replace debug signing with release signing when you supply the `key.properties` file.
