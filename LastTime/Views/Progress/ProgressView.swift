import SwiftUI

struct ProgressStatsView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @EnvironmentObject private var languageService: LanguageService

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    statsSection
                    ProgressChartView(data: viewModel.chartData)
                    achievementsSection
                }
                .padding()
            }
        }
        .navigationTitle(String(localized: String.LocalizationValue("progress.navigation_title"), locale: languageService.currentLocale))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadStats(locale: languageService.currentLocale)
        }
        .onChange(of: languageService.currentLocale) { _, newLocale in
            viewModel.loadStats(locale: newLocale)
        }
    }

    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(title: String(localized: String.LocalizationValue("progress.stat_activities"), locale: languageService.currentLocale), value: "\(viewModel.activitiesCount)")
                StatCard(title: String(localized: String.LocalizationValue("progress.stat_this_week"), locale: languageService.currentLocale), value: "\(viewModel.recordsThisWeek)")
                StatCard(title: String(localized: String.LocalizationValue("progress.stat_this_month"), locale: languageService.currentLocale), value: "\(viewModel.recordsThisMonth)")
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: String.LocalizationValue("progress.achievements"), locale: languageService.currentLocale))
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(viewModel.achievements) { achievement in
                HStack(spacing: 12) {
                    Image(systemName: achievement.icon)
                        .foregroundStyle(achievement.isUnlocked ? AppColors.accent : AppColors.textSecondary)
                    Text(String(localized: String.LocalizationValue(achievement.localizationKey), locale: languageService.currentLocale))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.accent)
                    }
                }
                .padding(12)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                        .stroke(AppColors.divider, lineWidth: 0.5)
                )
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .stroke(AppColors.divider, lineWidth: 0.5)
        )
    }
}

#Preview {
    ProgressStatsView()
        .environmentObject(LanguageService())
}
