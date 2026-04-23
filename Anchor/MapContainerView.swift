import SwiftUI
import MapKit
import SwiftData


struct MapContainerView: View {
    @Bindable var viewModel: AnchorViewModel
    @Environment(\.modelContext) private var modelContext

    @Query private var anchors: [AnchorItem]

    var body: some View {
        Map(position: $viewModel.mapCameraPosition) {
            UserAnnotation()

            ForEach(anchors) { anchor in
                Annotation(anchor.title, coordinate: anchor.coordinate) {
                    AnchorPinView(anchor: anchor)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35)) {
                                viewModel.flowState = .detail(anchor)
                                viewModel.centerOn(anchor)
                            }
                        }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            viewModel.locationManager.requestOnceIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.centerOnUser()
            }
        }
    }
}


struct AnchorPinView: View {
    let anchor: AnchorItem
    @State private var pressed = false

    var body: some View {
        ZStack {
            Circle()
                .fill(anchor.tag.color.opacity(0.25))
                .frame(width: 52, height: 52)
                .blur(radius: 4)
                .offset(y: 2)

            ZStack {
                Circle()
                    .fill(anchor.tag.color)
                    .frame(width: 40, height: 40)
                    .shadow(color: anchor.tag.color.opacity(0.5), radius: 6, y: 3)

                Text(anchor.mood.emoji)
                    .font(.system(size: 18))
            }

            Text(anchor.scoreGrade)
                .font(.system(size: 8, weight: .black))
                .foregroundStyle(.white)
                .padding(3)
                .background(anchor.gradeColor, in: Circle())
                .offset(x: 14, y: -14)
        }
        .scaleEffect(pressed ? 0.88 : 1.0)
        .animation(.spring(response: 0.25), value: pressed)
    }
}
