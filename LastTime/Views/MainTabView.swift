import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var languageService: LanguageService
    @State private var selectedTab = 0
    @State private var showOnboarding = !OnboardingService.hasCompletedOnboarding

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MainListView()
                    .environment(\.locale, languageService.currentLocale)
                    .id(languageService.currentLocale.identifier)
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("tab.main")
            }
            .tag(0)

            NavigationStack {
                TemplatesView(onTemplateAdded: { selectedTab = 0 })
                    .environment(\.locale, languageService.currentLocale)
                    .id(languageService.currentLocale.identifier)
            }
            .tabItem {
                Image(systemName: "square.grid.2x2")
                Text("tab.templates")
            }
            .tag(1)

            NavigationStack {
                ProgressStatsView()
                    .environment(\.locale, languageService.currentLocale)
                    .id(languageService.currentLocale.identifier)
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("tab.progress")
            }
            .tag(2)

            NavigationStack {
                SettingsView()
                    .environment(\.locale, languageService.currentLocale)
                    .id(languageService.currentLocale.identifier)
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("tab.settings")
            }
            .tag(3)
        }
        .tint(AppColors.accent)
        .onAppear {
            configureTabBarAppearance()
            showOnboarding = !OnboardingService.hasCompletedOnboarding
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                showOnboarding = false
            }
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.backgroundSecondary)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environmentObject(LanguageService())
        .environmentObject(PremiumService())
        .environmentObject(PaywallService())
}
