import SwiftUI

struct FilterBarView: View {
    @Binding var selectedFilter: MainListViewModel.MainListFilter
    @Environment(\.locale) private var locale

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MainListViewModel.MainListFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(String(localized: String.LocalizationValue(filter.localizationKey), locale: locale))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedFilter == filter ? AppColors.backgroundPrimary : AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? AppColors.accent : AppColors.backgroundSecondary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    FilterBarView(selectedFilter: .constant(.all))
        .padding()
        .background(AppColors.backgroundPrimary)
}
