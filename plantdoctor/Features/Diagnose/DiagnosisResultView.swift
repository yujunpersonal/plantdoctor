import PhotosUI
import SwiftUI

struct RediagnoseBinding {
    var additionalImages: Binding<[UIImage]>
    var isBusy: Bool
    var errorMessage: String?
    var maxAdditional: Int
    var onRemove: (Int) -> Void
    var onRediagnose: () -> Void
}

struct DiagnosisResultView: View {
    let response: DiagnosisResponse
    let image: UIImage?
    let onDone: () -> Void
    var rediagnose: RediagnoseBinding? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                headerBlock

                if !response.description.isEmpty {
                    AboutSection(title: L10n.Result.sectionAbout, text: response.description)
                }

                DetailSection(title: L10n.Result.sectionCauses, items: response.causes, systemImage: "magnifyingglass")
                DetailSection(title: L10n.Result.sectionFixes, items: response.fixes, systemImage: "wrench.and.screwdriver.fill")
                DetailSection(title: L10n.Result.sectionCareTips, items: response.careTips, systemImage: "leaf.fill")

                if hasAnyCareFacts {
                    PlantCareSection(
                        light: response.light,
                        water: response.water,
                        soil: response.soil,
                        temperature: response.temperature,
                        toxicity: response.toxicity,
                    )
                }

                if let rediagnose {
                    RediagnoseSection(binding: rediagnose)
                }

                Text(response.disclaimer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Button(L10n.Result.done, action: onDone)
                    .buttonStyle(LeafButtonStyle())
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Theme.cream.ignoresSafeArea())
        .navigationTitle(L10n.Result.navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hasAnyCareFacts: Bool {
        !(response.light.isEmpty
            && response.water.isEmpty
            && response.soil.isEmpty
            && response.temperature.isEmpty
            && response.toxicity.isEmpty)
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(response.plantName)
                .font(.title.bold())
            if !response.scientificName.isEmpty {
                Text(response.scientificName)
                    .font(.subheadline.italic())
                    .foregroundStyle(.secondary)
            }
            if !response.commonNames.isEmpty {
                Text(L10n.Result.alsoKnownAs(response.commonNames.joined(separator: ", ")))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                severityPill
                confidencePill
            }
            .padding(.top, 2)
            Text(response.condition)
                .font(.headline)
                .padding(.top, 4)
        }
    }

    private var severityPill: some View {
        let tint: Color = {
            switch Severity(rawValue: response.severity) ?? .mild {
            case .healthy: return .green
            case .mild: return .yellow
            case .moderate: return .orange
            case .severe: return .red
            }
        }()
        return Text(L10n.Severity.label(response.severity))
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.2))
            .foregroundStyle(tint)
            .clipShape(Capsule())
    }

    private var confidencePill: some View {
        Text(L10n.Result.confidence(Int(response.confidence * 100)))
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.leafLight.opacity(0.5))
            .clipShape(Capsule())
    }
}

private struct AboutSection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundStyle(Theme.leaf)
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }
}

private struct PlantCareSection: View {
    let light: String
    let water: String
    let soil: String
    let temperature: String
    let toxicity: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(L10n.Result.sectionPlantCare, systemImage: "drop.fill")
                .font(.headline)
                .foregroundStyle(Theme.leaf)
            VStack(spacing: 0) {
                row(label: L10n.Result.careLight, icon: "sun.max.fill", value: light, isFirst: true)
                row(label: L10n.Result.careWater, icon: "drop.fill", value: water, isFirst: false)
                row(label: L10n.Result.careSoil, icon: "tray.fill", value: soil, isFirst: false)
                row(label: L10n.Result.careTemperature, icon: "thermometer.medium", value: temperature, isFirst: false)
                row(label: L10n.Result.careToxicity, icon: "exclamationmark.triangle.fill", value: toxicity, isFirst: false)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func row(label: String, icon: String, value: String, isFirst: Bool) -> some View {
        if !value.isEmpty {
            if !isFirst {
                Divider()
            }
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.leaf)
                    .frame(width: 22, height: 22)
                    .background(Theme.leafLight.opacity(0.5))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

private struct RediagnoseSection: View {
    let binding: RediagnoseBinding

    @State private var showCamera = false
    @State private var photosItem: PhotosPickerItem?

    private var images: [UIImage] { binding.additionalImages.wrappedValue }
    private var canAddMore: Bool { images.count < binding.maxAdditional && !binding.isBusy }
    private var canRediagnose: Bool { !images.isEmpty && !binding.isBusy }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L10n.Result.rediagnoseTitle, systemImage: "questionmark.circle.fill")
                .font(.headline)
                .foregroundStyle(Theme.leaf)
            Text(L10n.Result.rediagnoseSubtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                            thumbnail(img: img, index: idx)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    showCamera = true
                } label: {
                    pickerChip(icon: "camera.fill", label: L10n.Result.rediagnoseAddCamera)
                }
                .buttonStyle(.plain)
                .disabled(!canAddMore)
                .opacity(canAddMore ? 1 : 0.4)

                PhotosPicker(selection: $photosItem, matching: .images, photoLibrary: .shared()) {
                    pickerChip(icon: "photo.on.rectangle.angled", label: L10n.Result.rediagnoseAddLibrary)
                }
                .buttonStyle(.plain)
                .disabled(!canAddMore)
                .opacity(canAddMore ? 1 : 0.4)
            }

            if let err = binding.errorMessage {
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                binding.onRediagnose()
            } label: {
                HStack(spacing: 8) {
                    if binding.isBusy {
                        ProgressView().tint(.white)
                        Text(L10n.Result.rediagnoseBusy)
                    } else {
                        Image(systemName: "sparkles")
                        Text(L10n.Result.rediagnoseCTA)
                        if !images.isEmpty {
                            Text("· \(L10n.Result.rediagnoseCount(images.count + 1))")
                                .opacity(0.85)
                        }
                    }
                }
            }
            .buttonStyle(LeafButtonStyle())
            .disabled(!canRediagnose)
            .opacity(canRediagnose ? 1 : 0.5)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
        .sheet(isPresented: $showCamera) {
            CameraPicker { img in
                let scaled = ImageResizer.downscaledForDisplay(img)
                var arr = binding.additionalImages.wrappedValue
                if arr.count < binding.maxAdditional {
                    arr.append(scaled)
                    binding.additionalImages.wrappedValue = arr
                }
            }
            .ignoresSafeArea()
        }
        .onChange(of: photosItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    let scaled = ImageResizer.downscaledForDisplay(image)
                    await MainActor.run {
                        var arr = binding.additionalImages.wrappedValue
                        if arr.count < binding.maxAdditional {
                            arr.append(scaled)
                            binding.additionalImages.wrappedValue = arr
                        }
                        photosItem = nil
                    }
                }
            }
        }
    }

    private func thumbnail(img: UIImage, index: Int) -> some View {
        Image(uiImage: img)
            .resizable()
            .scaledToFill()
            .frame(width: 74, height: 74)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.leafLight, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                Button {
                    binding.onRemove(index)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .offset(x: 4, y: -4)
                .disabled(binding.isBusy)
            }
    }

    private func pickerChip(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(Theme.leaf)
            Text(label)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Theme.leafLight.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct DetailSection: View {
    let title: String
    let items: [String]
    let systemImage: String

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(Theme.leaf)
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundStyle(Theme.leaf)
                            .padding(.top, 7)
                        Text(item)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.leafLight, lineWidth: 1)
            )
        }
    }
}
