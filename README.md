# MauNyuci Mobile 🧺

MauNyuci is a comprehensive multi-app platform for laundry management and services, built using **Flutter**. This repository is structured as a monorepo containing multiple interconnected applications and a shared core package.

## 📱 Project Structure

The workspace is divided into the following modules:

- **`maunyuci_core/`**: A shared Flutter package containing reusable components, API constants, base configurations, utilities, and common models used across all the apps.
- **`maunyuci_customer/`**: The mobile application for **Customers** to place laundry orders, track their laundry status, and manage their profiles.
- **`maunyuci_store/`**: The mobile application for **Laundry Stores/Owners** to manage inventory, incoming orders, expenses, and print receipts via thermal printers.
- **`maunyuci_driver/`**: The mobile application for **Drivers** to manage pick-ups and deliveries of laundry orders.

## 🛠️ Technology Stack

- **Framework**: Flutter (SDK >=3.0.0 <4.0.0)
- **State Management, Routing, & Dependency Injection**: [GetX](https://pub.dev/packages/get)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Mapping & Location**: [flutter_map](https://pub.dev/packages/flutter_map) (Leaflet) & geolocator
- **Push Notifications**: Firebase Cloud Messaging (FCM) & flutter_local_notifications
- **Local Storage**: flutter_secure_storage
- **Hardware Integration**: blue_thermal_printer (for Store receipt printing)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed.
- Android Studio / Xcode for device simulation.
- Ensure you have configured your environment for Flutter development.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd mau_nyuci
   ```

2. **Get dependencies for the Core package first:**
   ```bash
   cd maunyuci_core
   flutter pub get
   cd ..
   ```

3. **Get dependencies for the app you want to run (e.g., Store):**
   ```bash
   cd maunyuci_store
   flutter pub get
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```
   *(Repeat steps 3 and 4 for `maunyuci_customer` or `maunyuci_driver` as needed)*

## 📏 Architecture & Rules

- **Workspace Focus**: This repository only contains the mobile frontend (Flutter/Dart). Backend API interactions should point to the appropriate MauNyuci API server.
- **API Endpoints**: Any newly added module with a new endpoint must have its constant defined first in `api_constants.dart` (located in `maunyuci_core`). Do not hardcode endpoint strings directly in providers or repositories.
- **Shared UI/Logic**: Reusable widgets, themes, and logic should always be placed in `maunyuci_core` to maintain consistency across the Customer, Store, and Driver apps.

## 🤝 Contributing

When contributing to this repository:
1. Ensure your code conforms to the project's formatting and linting rules.
2. Keep the backend context separated (this is strictly a mobile workspace).
3. Thoroughly test changes, especially if modifying `maunyuci_core`, as it impacts all three applications.

---
*Developed for MauNyuci Laundry Management System.*
