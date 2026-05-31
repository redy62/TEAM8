//
//  MealoApp.swift
//  Mealo
//

import SwiftUI
import SwiftData

@main
struct MealoApp: App {

    let container: ModelContainer = {
        let schema = Schema([MealLog.self, UserProfile.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - RootView
// ─────────────────────────────────────────────────────────────────────────────

enum AppScreen { case splash, onboarding, promise, home }

struct RootView: View {

    @Query private var profiles: [UserProfile]
    @State private var screen: AppScreen = .splash

    var body: some View {
        Group {
            switch screen {
            case .splash:
                SplashView {
                    withAnimation { screen = profiles.isEmpty ? .onboarding : .home }
                }
            case .onboarding:
                SetYourPlanView {
                    withAnimation { screen = .promise }
                }
            case .promise:
                PromiseView {
                    withAnimation { screen = .home }
                }
            case .home:
                HomepageView()
            }
        }
        .onChange(of: profiles) {
            if screen == .onboarding && !profiles.isEmpty {
                withAnimation { screen = .home }
            }
        }
    }
}
