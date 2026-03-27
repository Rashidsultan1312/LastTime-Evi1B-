import SwiftUI

struct TemplatesView: View {
    @StateObject private var viewModel = TemplatesViewModel()
    @EnvironmentObject private var languageService: LanguageService
    var onTemplateAdded: (() -> Void)? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.templateKeys, id: \.self) { key in
                        TemplateCardView(
                            title: String(localized: String.LocalizationValue(key), locale: languageService.currentLocale),
                            isAdded: viewModel.isTemplateAdded(key: key, locale: languageService.currentLocale)
                        ) {
                            let localizedTitle = String(localized: String.LocalizationValue(key), locale: languageService.currentLocale)
                            let added = viewModel.addTemplate(title: localizedTitle)
                            if added {
                                onTemplateAdded?()
                            } else {
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.warning)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(String(localized: String.LocalizationValue("templates.navigation_title"), locale: languageService.currentLocale))
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    TemplatesView()
        .environmentObject(LanguageService())
}
