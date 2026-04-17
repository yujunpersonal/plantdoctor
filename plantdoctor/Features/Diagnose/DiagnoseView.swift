import PhotosUI
import SwiftData
import SwiftUI

struct DiagnoseView: View {
    @EnvironmentObject private var entitlement: EntitlementStore
    @EnvironmentObject private var creditsLedger: CreditsLedger
    @EnvironmentObject private var store: StoreManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: DiagnoseViewModel

    @State private var showCamera = false
    @State private var photosItem: PhotosPickerItem?

    init(entitlement: EntitlementStore) {
        _viewModel = StateObject(wrappedValue: DiagnoseViewModel(entitlement: entitlement))
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar(.hidden, for: .navigationBar)
                .sheet(isPresented: $showCamera) {
                    CameraPicker { img in
                        viewModel.selectedImage = ImageResizer.downscaledForDisplay(img)
                    }
                    .ignoresSafeArea()
                }
                .sheet(isPresented: $viewModel.showPaywall) {
                    PaywallView()
                }
                .alert("Slow down a bit", isPresented: $viewModel.showHourlyCapAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("You've done 100 diagnoses in the last hour. Take a short break and try again.")
                }
                .navigationDestination(item: $viewModel.result) { response in
                    DiagnosisResultView(
                        response: response,
                        image: viewModel.selectedImage,
                        onDone: { viewModel.clear() },
                    )
                }
        }
    }

    private var tierIcon: String {
        switch store.activeTier {
        case .some(.gold): return "crown.fill"
        case .some(.silver): return "star.fill"
        case .none: return "leaf.fill"
        }
    }

    private var tierAccent: Color {
        switch store.activeTier {
        case .some(.gold): return Color(red: 0xB8 / 255, green: 0x8A / 255, blue: 0x1E / 255)
        case .some(.silver): return Color(red: 0x6E / 255, green: 0x7A / 255, blue: 0x8A / 255)
        case .none: return Theme.leaf
        }
    }

    private var tierName: String {
        switch store.activeTier {
        case .some(.gold): return "Gold"
        case .some(.silver): return "Silver"
        case .none: return "Free"
        }
    }

    // MARK: - Plan strip

    @ViewBuilder
    private var planStrip: some View {
        if let tier = store.activeTier {
            HStack(spacing: 10) {
                tierBadge(tier: tier)
                creditsChip
            }
        } else {
            creditsCardFullWidth
        }
    }

    private func tierBadge(tier: SubscriptionTier) -> some View {
        let remaining = creditsLedger.subRemaining(for: tier)
        let used = tier.dailyQuota - remaining
        let progress = tier.dailyQuota > 0 ? Double(used) / Double(tier.dailyQuota) : 0
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: tierIcon)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(tierAccent))
                Text("\(tierName) plan")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(remaining) of \(tier.dailyQuota) today")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(tierAccent.opacity(0.15))
                        Capsule()
                            .fill(tierAccent)
                            .frame(width: max(0, geo.size.width * (1 - progress)))
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tierAccent.opacity(0.35), lineWidth: 1)
        )
    }

    private var creditsChip: some View {
        Button {
            viewModel.showPaywall = true
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.circle.fill")
                        .foregroundStyle(Theme.leaf)
                    Text("Credits")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    Image(systemName: "plus.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(Theme.leaf)
                }
                Text("\(creditsLedger.creditBalance)")
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(.primary)
            }
            .padding(12)
            .frame(width: 120, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.leafLight, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var creditsCardFullWidth: some View {
        Button {
            viewModel.showPaywall = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Theme.leaf.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "leaf.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.leaf)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(creditsLedger.creditBalance) credits")
                        .font(.body.bold())
                        .foregroundStyle(.primary)
                    Text("Tap to get more or go unlimited")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Theme.leafLight, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content phases

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .idle:
            idleContent
        case .analyzing:
            loadingContent
        case .failed(let message):
            failureContent(message)
        }
    }

    // MARK: - Idle

    private var idleContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroTitle
                planStrip
                preview
                pickerTiles
                primaryCTA
                tipCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .background(Theme.cream.ignoresSafeArea())
        .onChange(of: photosItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    let scaled = ImageResizer.downscaledForDisplay(image)
                    await MainActor.run { viewModel.selectedImage = scaled }
                }
            }
        }
    }

    private var heroTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Diagnose your plant")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
            Text("Snap a photo and get care tips in seconds.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var preview: some View {
        if let image = viewModel.selectedImage {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 340)
                .overlay(
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Theme.leafLight, lineWidth: 1)
                )
                .shadow(color: Theme.leaf.opacity(0.12), radius: 14, x: 0, y: 8)
                .overlay(alignment: .topTrailing) {
                    Button {
                        viewModel.selectedImage = nil
                        photosItem = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote.bold())
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.55))
                            .clipShape(Circle())
                    }
                    .padding(10)
                }
        } else {
            emptyPreview
        }
    }

    private var emptyPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Theme.leafLight.opacity(0.7), Theme.cream],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.leafLight, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))

            VStack(spacing: 14) {
                ZStack {
                    Circle().fill(.white)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Theme.leaf)
                }
                .frame(width: 64, height: 64)
                .shadow(color: Theme.leaf.opacity(0.15), radius: 10, x: 0, y: 6)

                VStack(spacing: 4) {
                    Text("Add a plant photo")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("Close-up, well-lit, affected leaves included.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
            .padding()
        }
        .frame(height: 340)
    }

    private var pickerTiles: some View {
        HStack(spacing: 12) {
            Button { showCamera = true } label: {
                pickerTile(icon: "camera.fill", title: "Camera", subtitle: "Take a photo")
            }
            .buttonStyle(.plain)

            PhotosPicker(selection: $photosItem, matching: .images, photoLibrary: .shared()) {
                pickerTile(icon: "photo.on.rectangle.angled", title: "Library", subtitle: "From your photos")
            }
            .buttonStyle(.plain)
        }
    }

    private func pickerTile(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.leaf.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.leaf)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.bold()).foregroundStyle(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var primaryCTA: some View {
        if viewModel.selectedImage != nil {
            Button {
                Task { await viewModel.diagnose(context: modelContext) }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Analyze plant")
                }
            }
            .buttonStyle(LeafButtonStyle())
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                Text("Photo tips")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
            }
            VStack(alignment: .leading, spacing: 6) {
                tipRow("Fill the frame with the plant")
                tipRow("Include affected leaves up close")
                tipRow("Natural daylight works best")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.leafLight, lineWidth: 1)
        )
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(Theme.leaf)
                .padding(.top, 2)
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Loading

    private var loadingContent: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .stroke(Theme.leafLight, lineWidth: 8)
                    .frame(width: 96, height: 96)
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(Theme.leaf, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(spinnerAngle))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spinnerAngle)
                Image(systemName: "leaf.fill")
                    .font(.title)
                    .foregroundStyle(Theme.leaf)
            }
            VStack(spacing: 4) {
                Text("Analyzing your plant…")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Reading leaves, color, and texture.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.cream.ignoresSafeArea())
        .onAppear { spinnerAngle = 360 }
        .onDisappear { spinnerAngle = 0 }
    }

    @State private var spinnerAngle: Double = 0

    // MARK: - Failure

    private func failureContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)
            }
            Text("Couldn't analyze")
                .font(.title3.bold())
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
            Button("Try again") { viewModel.phase = .idle }
                .buttonStyle(LeafButtonStyle())
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.cream.ignoresSafeArea())
    }
}

extension DiagnosisResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(plantName)
        hasher.combine(condition)
        hasher.combine(confidence)
    }
}
