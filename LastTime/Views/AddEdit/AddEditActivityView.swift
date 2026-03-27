import PhotosUI
import SwiftUI

struct AddEditActivityView: View {
    let activity: Activity?
    let onSave: () -> Void
    let onCancel: () -> Void

    @StateObject private var viewModel: AddEditActivityViewModel
    @EnvironmentObject private var languageService: LanguageService
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isCategoryPickerPresented = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    init(activity: Activity? = nil, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.activity = activity
        self.onSave = onSave
        self.onCancel = onCancel
        _viewModel = StateObject(wrappedValue: AddEditActivityViewModel(activity: activity))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()
                ScrollView {
                    formContent
                }
            }
            .navigationTitle(viewModel.isEditing ? String(localized: String.LocalizationValue("addedit.navigation_edit"), locale: locale) : String(localized: String.LocalizationValue("addedit.navigation_new"), locale: locale))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: String.LocalizationValue("addedit.cancel"), locale: locale)) {
                        onCancel()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: String.LocalizationValue("addedit.save"), locale: locale)) {
                        viewModel.save()
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.accent)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    guard let item = newItem else {
                        viewModel.removeImage()
                        return
                    }
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.setImage(uiImage)
                        }
                    }
                }
            }
            .onChange(of: viewModel.selectedReminder) { newReminder in
                if let rem = newReminder {
                    let base = activity?.lastDoneDate ?? Date()
                    viewModel.reminderAt = base.addingTimeInterval(rem.timeInterval)
                }
            }
            .sheet(isPresented: $viewModel.isReminderPickerPresented) {
                ReminderPickerView(
                    selectedReminder: $viewModel.selectedReminder,
                    onDismiss: { viewModel.isReminderPickerPresented = false }
                )
                .environment(\.locale, languageService.currentLocale)
            }
            .sheet(isPresented: $isCategoryPickerPresented) {
                CategoryPickerView(
                    selectedCategoryId: $viewModel.selectedCategoryId,
                    categories: viewModel.categories,
                    onDismiss: { isCategoryPickerPresented = false },
                    onCreateCategory: { name, colorHex in
                        viewModel.addCategory(name: name, colorHex: colorHex)?.id
                    }
                )
                .environment(\.locale, languageService.currentLocale)
            }
        }
    }

    private var formContent: some View {
        VStack(spacing: 24) {
            photoSection
            titleSection
            reminderButton
            reminderDateSection
            categoryButton
            Spacer()
        }
        .padding()
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("addedit.title_label")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            TextField(String(localized: String.LocalizationValue("addedit.name_placeholder"), locale: locale), text: $viewModel.title)
                .textFieldStyle(.plain)
                .padding(12)
                .foregroundStyle(AppColors.textPrimary)
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
        }
    }

    private var reminderButton: some View {
        Button {
            viewModel.isReminderPickerPresented = true
        } label: {
            HStack {
                Image(systemName: "bell")
                Text(viewModel.selectedReminder?.displayName(locale: locale) ?? String(localized: String.LocalizationValue("addedit.reminder_placeholder"), locale: locale))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.body)
            .foregroundStyle(AppColors.textPrimary)
            .padding(12)
            .background(AppColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var reminderDateSection: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("addedit.reminder_at_label")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                DatePicker(
                    "",
                    selection: $viewModel.reminderAt,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(AppColors.accent)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
            }
    }

    private var categoryButton: some View {
        Button {
            isCategoryPickerPresented = true
        } label: {
            HStack {
                Image(systemName: "folder")
                Text(categoryDisplayName)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.body)
            .foregroundStyle(AppColors.textPrimary)
            .padding(12)
            .background(AppColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
        }
    }

    private var categoryDisplayName: String {
        guard let id = viewModel.selectedCategoryId,
              let cat = viewModel.categories.first(where: { $0.id == id }) else {
            return String(localized: String.LocalizationValue("category.none"), locale: locale)
        }
        return cat.name
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("addedit.photo_label")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            if let image = viewModel.selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))

                    Button {
                        viewModel.removeImage()
                        selectedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .padding(8)
                }
            } else {
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images
                ) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColors.textSecondary)
                        Text("addedit.add_photo")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.inputCornerRadius)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(AppColors.divider)
                    )
                }
            }
        }
    }
}

#Preview {
    AddEditActivityView(onSave: {}, onCancel: {})
        .environmentObject(LanguageService())
}
