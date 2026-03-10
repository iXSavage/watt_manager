# ⚡ Watt Manager

Watt Manager is a beautifully designed, responsive Flutter application built to help users seamlessly monitor and manage their inverter and battery power loads. Calculate estimated runtimes, track connected appliances, and receive critical notifications to prevent system overloads.

## 📱 Features

*   **Real-time Load Monitoring**: Track your total connected load against your inverter's maximum capacity.
*   **Battery Runtime Estimation**: Automatically calculates your estimated remaining battery runtime based on current usage.
*   **Appliance Management**: Add, edit, remove, and toggle individual appliances to see their immediate impact on your power system.
*   **Responsive Layout**: Fully adaptive UI that looks perfectly balanced on both small smartphones and large tablet screens.
*   **Smart Notifications**: Receive alerts for low battery percentages or when your system is approaching an overload limit.
*   **Local Persistence**: Your settings and appliance configurations are securely saved locally using Hive.

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
    git clone https://github.com/your_username/watt_manager.git
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

*(Coming Soon! Add 2-3 screenshots of your app running on different device sizes here.)*
<!-- Example:
<img src="doc/screenshot_1.png" width="250"> <img src="doc/screenshot_2.png" width="250">
-->

## 🔒 Security

*   Ensure that any Android keystore `.jks` profiles and `key.properties` are kept strictly out of version control. The `.gitignore` is pre-configured to handle this out of the box.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
