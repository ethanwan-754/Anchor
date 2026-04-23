import SwiftUI
import SwiftData
import Observation

struct RootView: View {

    @State private var viewModel = AnchorViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {

            MapContainerView(viewModel: viewModel)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TopHUD(viewModel: viewModel)
                Spacer()
                BottomHUD(viewModel: viewModel)
            }

            if let msg = viewModel.toastMessage {
                ToastView(message: msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4), value: viewModel.toastMessage)
                    .zIndex(99)
            }
        }

        .sheet(isPresented: Binding<Bool>(
            get: { viewModel.flowState == .addAnchor },
            set: { if !$0 { viewModel.flowState = .map } }
        )) {
            AddAnchorSheet(viewModel: viewModel)
                .presentationDetents([.large])
        }

        .sheet(item: Binding<AnchorItem?>(
            get: {
                if case .detail(let anchor) = viewModel.flowState {
                    return anchor
                }
                return nil
            },
            set: { _ in
                viewModel.flowState = .map
            }
        )) { anchor in
            AnchorDetailSheet(anchor: anchor, viewModel: viewModel)
        }

        .sheet(isPresented: Binding<Bool>(
            get: { viewModel.flowState == .stats },
            set: { if !$0 { viewModel.flowState = .map } }
        )) {
            StatsView(viewModel: viewModel)
        }

        .alert(
            viewModel.currentError?.localizedDescription ?? "Error",
            isPresented: Binding(
                get: { viewModel.showErrorAlert },
                set: { viewModel.showErrorAlert = $0 }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let suggestion = viewModel.currentError?.recoverySuggestion {
                Text(suggestion)
            }
        }
    }
}
