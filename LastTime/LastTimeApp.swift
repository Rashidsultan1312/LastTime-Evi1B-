import SwiftUI
import UIKit

@main
struct LastTimeApp: App {
    @StateObject private var languageService = LanguageService()
    @StateObject private var premiumService = PremiumService()
    @State private var isLaunchComplete = false

    init() {
        configureNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLaunchComplete {
                    MainTabView()
                        .environmentObject(languageService)
                        .environmentObject(premiumService)
                        .environment(\.locale, languageService.currentLocale)
                        .transition(.opacity)
                } else {
                    LoadingView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isLaunchComplete)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    isLaunchComplete = true
                }
            }
        }
    }

    private func configureNavigationBarAppearance() {
        let titleColor = UIColor(AppColors.textPrimary)
        let navBar = UINavigationBar.appearance()
        navBar.tintColor = UIColor(AppColors.accent)

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(AppColors.backgroundPrimary)
        standardAppearance.titleTextAttributes = [.foregroundColor: titleColor]
        standardAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        navBar.standardAppearance = standardAppearance
        navBar.compactAppearance = standardAppearance

        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.backgroundColor = .clear
        scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: titleColor]
        scrollEdgeAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        navBar.scrollEdgeAppearance = scrollEdgeAppearance
    }
}
