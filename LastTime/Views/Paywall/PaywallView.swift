import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var premiumService: PremiumService
    @StateObject private var viewModel: PaywallViewModel
    let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void, paywallService: PaywallService) {
        self.onDismiss = onDismiss
        _viewModel = StateObject(wrappedValue: PaywallViewModel(paywallService: paywallService))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        benefitsSection
                        subscriptionOptionsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                bottomSection
            }
        }
        .environment(\.locale, languageService.currentLocale)
        .task {
            await viewModel.loadProducts()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 52))
                .foregroundStyle(AppColors.accent)

            Text(String(localized: String.LocalizationValue("paywall.title"), locale: languageService.currentLocale))
                .font(.title.bold())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: String.LocalizationValue("paywall.subtitle"), locale: languageService.currentLocale))
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var benefitsSection: some View {
        VStack(spacing: 12) {
            ForEach(PaywallBenefit.all) { benefit in
                HStack(spacing: 12) {
                    Image(systemName: benefit.systemImageName)
                        .font(.body)
                        .foregroundStyle(AppColors.accent)
                        .frame(width: 24, alignment: .center)
                    Text(String(localized: String.LocalizationValue(benefit.titleKey), locale: languageService.currentLocale))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                        .stroke(AppColors.divider, lineWidth: 0.5)
                )
            }
        }
    }

    private var subscriptionOptionsSection: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.options) { option in
                subscriptionCard(option: option)
            }
        }
    }

    private func subscriptionCard(option: SubscriptionOption) -> some View {
        let isSelected = viewModel.selectedOption.id == option.id
        return Button {
            viewModel.select(option)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(String(localized: String.LocalizationValue(option.titleKey), locale: languageService.currentLocale))
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        if option.isBestValue {
                            Text(String(localized: String.LocalizationValue("paywall.best_value"), locale: languageService.currentLocale))
                                .font(.caption2.bold())
                                .foregroundStyle(AppColors.backgroundPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    Text(String(localized: String.LocalizationValue(option.priceKey), locale: languageService.currentLocale))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Text(viewModel.priceString(for: option))
                    .font(.title3.bold())
                    .foregroundStyle(AppColors.accent)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                    .stroke(isSelected ? AppColors.accent : AppColors.divider, lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var bottomSection: some View {
        VStack(spacing: 16) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppColors.danger)
            }

            Button {
                viewModel.purchase { success in
                    if success {
                        premiumService.activatePremium()
                        onDismiss()
                    }
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.backgroundPrimary))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(String(localized: String.LocalizationValue("paywall.continue"), locale: languageService.currentLocale))
                            .font(.headline)
                            .foregroundStyle(AppColors.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(AppColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.buttonCornerRadius))
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(ScaleButtonStyle())

            Button {
                viewModel.restorePurchases { restored in
                    if restored {
                        premiumService.activatePremium()
                        onDismiss()
                    }
                }
            } label: {
                Text(String(localized: String.LocalizationValue("paywall.restore"), locale: languageService.currentLocale))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(.plain)

            HStack(spacing: 16) {
                Button {
                    if let url = URL(string: AppConstants.URLs.privacyPolicy) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(String(localized: String.LocalizationValue("paywall.privacy_policy"), locale: languageService.currentLocale))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)

                Text("•")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Button {
                    if let url = URL(string: AppConstants.URLs.termsOfUse) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(String(localized: String.LocalizationValue("paywall.terms"), locale: languageService.currentLocale))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)

                Text("•")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Button {
                    if let url = URL(string: AppConstants.URLs.support) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(String(localized: String.LocalizationValue("paywall.support"), locale: languageService.currentLocale))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .padding(.top, 8)
        .background(AppColors.backgroundPrimary.opacity(0.3))
    }
}

#Preview {
    PaywallView(onDismiss: {}, paywallService: PaywallService())
        .environmentObject(LanguageService())
        .environmentObject(PremiumService())
}
