import SwiftUI
import SwiftData
import CoreLocation


struct TopHUD: View {
    @Bindable var viewModel: AnchorViewModel

    @Query private var anchors: [AnchorItem]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // App wordmark
            VStack(alignment: .leading, spacing: 2) {
                Text("ANCHOR")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AnchorDesign.primary)
                HStack(spacing: 6) {
                    Circle()
                        .fill(locationStatusColor)
                        .frame(width: 7, height: 7)
                    Text(locationStatusText)
                        .font(AnchorDesign.captionFont)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                viewModel.flowState = .stats
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AnchorDesign.accent)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }

            Button {
                viewModel.centerOnUser()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AnchorDesign.accent)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0.92), .clear],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private var locationStatusColor: Color {
        switch viewModel.locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return viewModel.locationManager.userLocation != nil ? .green : .orange
        case .denied, .restricted:
            return .red
        default:
            return .orange
        }
    }

    private var locationStatusText: String {
        switch viewModel.locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return viewModel.locationManager.userLocation != nil ? "Location active" : "Locating…"
        case .denied:
            return "Location denied"
        default:
            return "Requesting location…"
        }
    }
}


struct BottomHUD: View {
    @Bindable var viewModel: AnchorViewModel
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \AnchorItem.date, order: .reverse) private var anchors: [AnchorItem]

    var body: some View {
        VStack(spacing: 10) {
      
            if !anchors.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(anchors.prefix(8)) { anchor in
                            AnchorChip(anchor: anchor)
                                .onTapGesture {
                                    viewModel.flowState = .detail(anchor)
                                    viewModel.centerOn(anchor)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            Button {
                viewModel.beginAddAnchor()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Drop Anchor")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [AnchorDesign.accent, AnchorDesign.accentAlt],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(color: AnchorDesign.accent.opacity(0.45), radius: 14, y: 6)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(
            LinearGradient(
                colors: [.clear, Color(.systemBackground).opacity(0.94)],
                startPoint: .top, endPoint: .bottom
            )
        )
    }
}


struct AnchorChip: View {
    let anchor: AnchorItem

    var body: some View {
        HStack(spacing: 7) {
            Text(anchor.mood.emoji)
                .font(.system(size: 15))

            VStack(alignment: .leading, spacing: 1) {
                Text(anchor.title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                HStack(spacing: 4) {
                    Image(systemName: anchor.environment.systemIcon)
                        .font(.system(size: 9))
                    Text(anchor.environment.rawValue)
                        .font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
            }

            Text("S:\(anchor.score)")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(anchor.gradeColor, in: Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: 185)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AnchorDesign.chipRadius))
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
    }
}


struct ToastView: View {
    let message: String
    var body: some View {
        VStack {
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(AnchorDesign.primary.opacity(0.92), in: Capsule())
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            Spacer()
        }
        .padding(.top, 64)
        .allowsHitTesting(false)
    }
}
