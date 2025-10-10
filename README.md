# IvenTrack


IvenTrack is a **lightweight, local-first** inventory management application built with **Flutter**. It's designed for personal use, allowing users to track grocery stock, monitor expiry dates, and manage quantities entirely offline.

The primary goal of this project is to provide a fast, private, and reliable utility app with **zero dependency on network services** or cloud sign-in.

--

## ✨ Key Features (MVP)

* **Full Offline Usability:** All data is stored locally on the device using SQLite.
* **Inventory Management:** Add, edit, and delete grocery items with details like category, quantity, unit, and expiry date.
* **Expiry Reminders:** Uses **Flutter Local Notifications** to schedule time-zone aware alerts for items nearing expiration.
* **Image Attachments:** Supports storing local device paths for item photos (`image_picker`).
* **Consumption Insights:** Basic charts show item distribution by category (`fl_chart`).

--

## 🛠️ Technology Stack

| Layer | Technology | Rationale |
| :--- | :--- | :--- |
| **Frontend/UI** | **Flutter (Dart)** | Cross-platform UI development. |
| **State Management** | **Provider** | Simple and scalable state handling for local data. |
| **Database** | **SQLite (via `sqflite` package)** | Fast, persistent, and entirely local storage solution. |
| **Notifications** | **`flutter_local_notifications`** | Schedules time-zone aware, offline alerts. |
| **Charting** | **`fl_chart`** | Provides robust, customizable charts for insights. |
| **Image Handling**| **`image_picker`** | Handles local image selection/capture. |

--

## 🏗️ Architecture and Workflow

The application follows a clean, layered architecture focused on the local database.

### 🔄 Data Flow

1.  **UI (Widgets):** Triggers an action (e.g., adding an item).
2.  **Provider (ChangeNotifier):** Receives the action, performs business logic, and notifies listeners.
3.  **Database Helper (`DatabaseHelper`):** Executes the necessary CRUD operation via the `sqflite` package.
4.  **SQLite Database:** Persists or retrieves data from the local file system.
5.  **Notifications:** The Provider also calls the `NotificationService` to schedule an alert immediately after an item is saved or updated.

### 🗄️ Database Structure

The project currently uses **one primary table** to store all grocery item details.

| Table Name | Description |
| :--- | :--- |
| **`groceries`** | Stores all core inventory data, including name, quantity, dates, and image paths. |

#### **`groceries` Table Schema**

| Column | Data Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER` (PK) | Unique auto-incrementing item ID. |
| `name` | `TEXT` | Item name (e.g., "Milk"). |
| `category` | `TEXT` | Item category (e.g., "Dairy"). |
| `quantity` | `REAL` | Current stock level. |
| `unit` | `TEXT` | Unit of measure (e.g., "L", "pcs", "kg"). |
| `expiry_date` | `TEXT` | Expiration date (stored as ISO 8601 string). |
| `image_path` | `TEXT` | Local file path to the item's photo (nullable). |
| `created_at`| `TEXT` | Date the item was first added. |

--

## 🚀 Getting Started

To run this project locally, ensure you have Flutter installed and configured.

### Prerequisites

1.  Flutter SDK (Stable Channel)
2.  An IDE (VS Code or Android Studio)
3.  JDK 11 or higher (required for recent Android development)

### Setup

1.  Clone the repository:
    ```bash
    git clone [REPOSITORY_URL]
    ```
2.  Fetch dependencies:
    ```bash
    flutter pub get
    ```
3.  **Fix Android Native Dependencies (Crucial for Notifications):**
    * Open `android/app/build.gradle` and ensure the following configurations are set to handle modern Java APIs and resolve compilation issues:
        ```gradle
        // Inside the android block:
        compileOptions {
            sourceCompatibility JavaVersion.VERSION_11
            targetCompatibility JavaVersion.VERSION_11
            coreLibraryDesugaringEnabled true 
        }
        
        // Inside the dependencies block:
        dependencies {
            // Ensure this is present for desugaring:
            coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4' 
            // ... other dependencies
        }
        ```
4.  Run the app:
    ```bash
    flutter run
    ```

--

## 🤝 Contribution Guide

We welcome contributions! Please check the [Issues]([https://github.com/ossdaiict/SLoP5.0-App-Development/issues]) tab for tasks ranging from UI polish to new feature development.

### How to Contribute

1.  Fork the repository.
2.  Create a descriptive branch (e.g., `feature/low-stock-highlight`).
3.  Commit your changes following a clear convention (e.g., `feat: Added category chart to stats screen`).
4.  Open a Pull Request (PR) describing the changes and linking to the relevant issue.

**Look for issues tagged `good first issue` or `enhancement` to get started!**