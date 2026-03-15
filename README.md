# ⚡ Watt Manager

Watt Manager is a beautifully designed, responsive Flutter application built to help users seamlessly monitor and manage their inverter and battery power loads. Calculate estimated runtimes, track connected appliances, and receive critical notifications to prevent system overloads.

## 📱 Features

*   **Real-time Load Monitoring**: Track your total connected load against your inverter's maximum capacity.
*   **Battery Runtime Estimation**: Automatically calculates your estimated remaining battery runtime based on current usage.
*   **Appliance Management**: Add, edit, remove, and toggle individual appliances to see their immediate impact on your power system.
*   **Responsive Layout**: Fully adaptive UI that looks perfectly balanced on both small smartphones and large tablet screens.
*   **Smart Notifications**: Receive alerts for low battery percentages or when your system is approaching an overload limit.
*   **Local Persistence**: Your settings and appliance configurations are securely saved locally using Hive.

---
📦 Download APK

[Download Latest APK](https://github.com/iXSavage/watt_manager/releases/tag/v1.0.0)

---

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **State Management**: `provider`
*   **Local Storage**: `hive_ce`
*   **Notifications**: `flutter_local_notifications`
*   **Animations**: `lottie`

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK (^3.7.2)
*   Dart SDK

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/iXSavage/watt_manager.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd watt_manager
    ```
3.  Install the dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the application (on simulator or physical device):
    ```bash
    flutter run
    ```

## 📸 Screenshots
<img width="308" height="621" alt="Screenshot 2026-03-11 at 00 08 38" src="https://github.com/user-attachments/assets/8a54d153-2c1c-4df8-b667-90ad2edc0cd6" />

<img width="308" height="621" alt="Screenshot 2026-03-11 at 00 09 02" src="https://github.com/user-attachments/assets/562d154a-7360-4f34-b720-6401325ff787" />

<img width="308" height="621" alt="Screenshot 2026-03-11 at 00 09 38" src="https://github.com/user-attachments/assets/fd77815f-df6c-48d2-8ce9-2049290242c7" />

## 🔒 Security

*   Ensure that any Android keystore `.jks` profiles and `key.properties` are kept strictly out of version control. The `.gitignore` is pre-configured to handle this out of the box.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
