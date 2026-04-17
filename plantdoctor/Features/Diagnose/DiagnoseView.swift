import PhotosUI
import SwiftData
import SwiftUI

struct DiagnoseView: View {
    @EnvironmentObject private var entitlement: EntitlementStore
    @EnvironmentObject private var creditsLedger: CreditsLedger
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
                .navigationTitle("Leafwise")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(entitlement.statusText)
                            .font(.caption)
                            .foregroundStyle(Theme.leaf)
                    }
                }
                .sheet(isPresented: $showCamera) {
                    CameraPicker { img in
                        viewModel.selectedImage = img
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

    private var idleContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                preview

                HStack(spacing: 12) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.leaf)

                    PhotosPicker(selection: $photosItem, matching: .images, photoLibrary: .shared()) {
                        Label("Library", systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.leaf)
                }
                .onChange(of: photosItem) { _, newValue in
                    guard let newValue else { return }
                    Task {
                        if let data = try? await newValue.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                viewModel.selectedImage = image
                            }
                        }
                    }
                }

                if viewModel.selectedImage != nil {
                    Button {
                        Task { await viewModel.diagnose(context: modelContext) }
                    } label: {
                        Label("Analyze plant", systemImage: "sparkles")
                    }
                    .buttonStyle(LeafButtonStyle())
                }

                tipCard
            }
            .padding(20)
        }
        .background(Theme.cream.ignoresSafeArea())
    }

    private var preview: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 320)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Theme.leafLight.opacity(0.35))
                    VStack(spacing: 10) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(Theme.leaf)
                        Text("Snap or pick a photo of your plant")
                            .font(.headline)
                            .foregroundStyle(Theme.leaf)
                        Text("We'll identify it and flag any issues.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .frame(height: 320)
            }
        }
    }

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Better photos, better diagnoses", systemImage: "lightbulb.fill")
                .font(.subheadline.bold())
                .foregroundStyle(Theme.leaf)
            Text("Fill the frame with the plant. Include affected leaves up close. Natural daylight works best.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.leafLight, lineWidth: 1))
    }

    private var loadingContent: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .tint(Theme.leaf)
            Text("Analyzing your plant…")
                .font(.headline)
                .foregroundStyle(Theme.leaf)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.cream.ignoresSafeArea())
    }

    private func failureContent(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
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
