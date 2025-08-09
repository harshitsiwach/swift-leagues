# VisionOS Porting Guide: CryptoLeagues

This document provides a comprehensive guide for porting the existing "CryptoLeagues" iOS application to visionOS. It includes an overview of the original iOS app, its architecture, and a step-by-step plan for recreating it in the visionOS environment.

## 1. iOS App Overview

**Name:** CryptoLeagues
**Purpose:** A fantasy league application based on cryptocurrencies. Users select a team of 5 cryptocurrencies, and their performance is tracked.

### Core Features:

*   **Cryptocurrency Data:** Fetches real-time cryptocurrency data (price, name, symbol, 24-hour change) from the CoinGecko API.
*   **Team Selection:** Allows users to select a team of up to 5 cryptocurrencies.
*   **Team Submission:** Saves the user's selected team to a Supabase backend, linking it to their wallet address.
*   **Wallet Integration:**
    *   Connects to Ethereum-based wallets.
    *   The current implementation uses a manual address input for connection, but UI exists for selecting wallets like MetaMask, Rainbow, and Trust Wallet.
    *   Fetches wallet balance and chain ID. It is configured for the BASE Sepolia Testnet.
*   **User Interface:**
    *   A modern SwiftUI application.
    *   Supports both dark and light modes.
    *   Utilizes "glass" effects for UI elements.
    *   Features tab-based navigation for "Home," "My team," "Contest," "Ranking," and "Latest."
    *   Includes a news slideshow.
    *   Provides search functionality for cryptocurrencies.

### Dependencies:

*   **Supabase:** For the backend database.
*   **Web3.swift:** For interacting with the Ethereum blockchain.
*   **CoinGecko API:** For cryptocurrency market data.

## 2. iOS Project Structure

*   `swift_leaguesApp.swift`: The main entry point of the application.
*   `ContentView.swift`: The main view of the application, containing the UI and the `CoinViewModel`.
*   `CoinViewModel.swift` (within `ContentView.swift`): The view model responsible for fetching coin data and managing the user's team.
*   `SupabaseManager.swift`: Manages the connection and data submission to the Supabase backend.
*   `WalletManager.swift`: Handles wallet connection, balance fetching, and other Web3-related logic.
*   `WalletSelectionView.swift`: A view for selecting a wallet to connect with.
*   `WalletConnectionView.swift`: A view that shows the wallet connection status and provides a button to connect/disconnect.
*   `CryptoLeagues Database Schema.txt`: Contains the database schema.
*   `.env`: Contains the Supabase URL and Key.

## 3. Porting to visionOS: Step-by-Step Guide

This guide will walk you through the process of recreating the CryptoLeagues app for visionOS, focusing on adapting the UI for a spatial computing environment.

### Step 1: Project Setup

1.  **Create a new visionOS Project:** In Xcode, create a new project using the "visionOS App" template.
2.  **Add Dependencies:** Add the `Supabase` and `Web3.swift` Swift Package Manager dependencies to your new project.
3.  **Environment Variables:** Configure the Supabase URL and Key in your new project's scheme environment variables, similar to the iOS project.

### Step 2: Porting Core Logic

1.  **Copy Logic Files:** Copy the following files from the iOS project to your new visionOS project:
    *   `SupabaseManager.swift`
    *   `WalletManager.swift`
    *   The `Coin` and `NewsArticle` data models.
    *   The `CoinViewModel` class.
2.  **Adapt for visionOS:**
    *   Review the copied files for any iOS-specific APIs that need to be adapted for visionOS (e.g., `UIKit` dependencies). Most of the logic in these files should be platform-agnostic.
    *   The `WalletManager` might need adjustments depending on how wallet connections are handled in visionOS. Initially, you can maintain the manual address input method.

### Step 3: Recreating the UI for visionOS

This is the most significant part of the porting process. You will recreate the UI from scratch to take advantage of visionOS's unique capabilities.

1.  **Main Window:**
    *   Start with a `WindowGroup` in your main app file.
    *   The main `ContentView` will be the root of your application's UI.

2.  **Layout and Navigation:**
    *   Instead of a bottom tab bar, consider using a `TabView` with a leading-edge tab bar style, which is more common in visionOS.
    *   Use `NavigationSplitView` for a more robust navigation structure if needed, especially for the "Contest" and "Ranking" sections.

3.  **Glass Effects and Spatial UI:**
    *   Replace the custom glass effects with visionOS's native `glassBackgroundEffect`.
    *   Use `depth` and `shadow` modifiers to create a sense of hierarchy and visual separation between UI elements.
    *   Place interactive elements like buttons and sliders on `ornaments` to make them easily accessible.

4.  **Recreating Views:**

    *   **HeaderView:**
        *   The search bar can be implemented using the `.searchable` modifier on your main view.
        *   The wallet connection and theme toggle buttons can be placed in the toolbar.

    *   **News Slideshow:**
        *   Instead of a 2D slideshow, consider a 3D carousel of news cards using `TabView` with a 3D rotation effect.

    *   **Coin List:**
        *   Display the list of coins in a `List` or a `ScrollView`.
        *   Each coin row can be a separate view with a `glassBackgroundEffect`.
        *   Use hover effects to provide visual feedback when the user looks at a coin row.

    *   **Team Popup:**
        *   When the user views their team, present it in a modal sheet using the `.sheet` modifier.
        *   The sheet should have a `glassBackgroundEffect`.

    *   **Wallet Selection:**
        *   The wallet selection view can also be presented as a modal sheet.

### Step 4: Handling Input

*   Adapt the UI to work with eye tracking and gestures.
*   Ensure that all buttons and interactive elements have a clear hover effect and are large enough to be easily targeted.

### Step 5: Testing and Refinement

*   Thoroughly test the app in the visionOS simulator and on a device if available.
*   Pay close attention to performance, especially with the glass effects and 3D elements.
*   Refine the UI and interactions based on user feedback and testing.

## 4. Example Code Snippets for visionOS

Here are some example code snippets to help you get started with the visionOS UI:

**Glass Background Effect:**

```swift
struct CoinRowView: View {
    let coin: Coin

    var body: some View {
        HStack {
            // ... content ...
        }
        .padding()
        .glassBackgroundEffect()
    }
}
```

**Spatial Button:**

```swift
Button(action: {
    // ... action ...
}) {
    Text("Submit Team")
}
.buttonStyle(.borderedProminent)
```

**Toolbar:**

```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button(action: {
            // ... connect wallet ...
        }) {
            Image(systemName: "wallet.pass")
        }
    }
}
```

By following this guide, you should be able to successfully port the CryptoLeagues application to visionOS, creating a compelling spatial experience for your users.
