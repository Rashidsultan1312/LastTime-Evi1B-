import SwiftUI

struct DashboardSummaryView: View {
    let overdueCount: Int
    let dueThisWeekCount: Int
    let doneTodayCount: Int
    let onOverdueTap: () -> Void
    @Environment(\.locale) private var locale

    var body: some View {
        HStack(spacing: 12) {
            if overdueCount > 0 {
                Button(action: onOverdueTap) {
                    HStack(spacing: 4) {
                        Text("\(overdueCount)")
                            .font(.subheadline.bold())
                        Text(String(localized: String.LocalizationValue("dashboard.overdue"), locale: locale))
                            .font(.caption)
                    }
                    .foregroundStyle(AppColors.backgroundPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.danger)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            DashboardChip(
                value: dueThisWeekCount,
                labelKey: "dashboard.due_this_week",
                locale: locale
            )
            DashboardChip(
                value: doneTodayCount,
                labelKey: "dashboard.done_today",
                locale: locale
            )
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}

private struct DashboardChip: View {
    let value: Int
    let labelKey: String
    let locale: Locale

    var body: some View {
        HStack(spacing: 4) {
            Text("\(value)")
                .font(.subheadline.bold())
            Text(String(localized: String.LocalizationValue(labelKey), locale: locale))
                .font(.caption)
        }
        .foregroundStyle(AppColors.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.backgroundSecondary)
        .clipShape(Capsule())
    }
}
