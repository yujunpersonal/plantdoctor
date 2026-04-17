import SwiftUI

struct LanguagePickerView: View {
    @EnvironmentObject private var language: LanguageStore

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(AppLanguage.allCases.enumerated()), id: \.element) { index, option in
                    Button { language.current = option } label: {
                        HStack(spacing: 14) {
                            Text(option.displayName)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            if language.current == option {
                                Image(systemName: "checkmark")
                                    .font(.footnote.weight(.bold))
                                    .foregroundStyle(Theme.leaf)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < AppLanguage.allCases.count - 1 {
                        Rectangle()
                            .fill(Theme.leafLight.opacity(0.5))
                            .frame(height: 1)
                            .padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.leafLight, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Theme.cream.ignoresSafeArea())
        .navigationTitle(L10n.Settings.languagePickerTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
