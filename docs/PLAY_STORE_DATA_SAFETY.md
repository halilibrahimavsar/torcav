# Google Play Data Safety Inventory - Torcav

This document provides the inventory required for the Google Play Data Safety form, based on the codebase as of 2026-04-23.

## Data Collection and Sharing

**Torcav does NOT share any user data with third parties.** All data is processed locally on the device.

### 1. Location (Hassas)
- **Data type**: Approximate location, Precise location.
- **Requirement**: Android system requirement for Wi-Fi scanning.
- **Usage**: App functionality (to discover nearby networks).
- **Sharing**: NO.
- **Persistence**: NO (used only during scan).

### 2. Device or Other IDs
- **Data type**: BSSID, MAC Addresses, Hostnames.
- **Usage**: App functionality (Network analysis, topology mapping, device classification).
- **Sharing**: NO.
- **Persistence**: YES (stored in local SQLite database). Users can delete via "Wipe All Data".

### 3. App Activity
- **Data type**: App interactions, Search history (in-app).
- **Usage**: Analytics (Local only), Personalization (Favorites).
- **Sharing**: NO.
- **Persistence**: YES (local database).

### 4. Health and Fitness
- **Data type**: Sensors (Accelerometer/Activity Recognition).
- **Usage**: App functionality (Signal heatmap surveys).
- **Sharing**: NO.
- **Persistence**: YES (local database).
- **Note**: `BODY_SENSORS` permission has been explicitly removed to avoid health policy scrutiny.

## Security Practices
- **Data encryption**: All data is stored in a local SQLite database within the app's private storage.
- **Data deletion**: Users can request data deletion via "Settings > Wipe All Local Data". Data is also automatically cleared based on the user-configurable retention period.

## Required Permissions Justification

| Permission | Reason |
|---|---|
| `ACCESS_FINE_LOCATION` | Required by Android to perform Wi-Fi scans. |
| `CAMERA` | Used for AR/Heatmap visualization. |
| `ACTIVITY_RECOGNITION` | Used to track movement during signal surveys. |
| `INTERNET` | Used for speed tests and DNS integrity checks. |
