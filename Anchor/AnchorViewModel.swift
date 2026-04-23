import Foundation
import CoreLocation
import MapKit
import SwiftData
import SwiftUI


@Observable
final class AnchorViewModel {


    let locationManager = LocationManager()

    var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.9049, longitude: -79.0469), // Chapel Hill default
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    var mapCameraPosition: MapCameraPosition = .automatic

    var flowState: AppFlowState = .map

    var geocodingState: LoadingState<ReverseGeocodeResult> = .idle

    var draftTitle       = ""
    var draftNote        = ""
    var draftTag: AnchorTag = .memory
    var draftMood: Mood  = .neutral
    var draftEnvironment: AnchorEnvironment = .unknown
    var draftAutoAddress: String?

    var toastMessage: String?
    var showErrorAlert = false
    var currentError: AppError?

    var sortOrder: StatSortOrder = .score

    func centerOnUser() {
        guard let coord = locationManager.userLocation else {
            showError(.locationUnavailable)
            return
        }
        withAnimation {
            mapCameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        }
    }

    func centerOn(_ anchor: AnchorItem) {
        withAnimation {
            mapCameraPosition = .region(MKCoordinateRegion(
                center: anchor.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            ))
        }
    }



    func beginAddAnchor() {
        resetDraft()
        flowState = .addAnchor

        guard let coord = locationManager.userLocation else {
            geocodingState = .failure(.locationUnavailable)
            return
        }

        geocodingState = .loading

     
        Task {
            do {
             
                let result = try await GeocodingService.reverseGeocode(coordinate: coord)

              
                await MainActor.run {
                    geocodingState = .success(result)
                    draftAutoAddress = result.shortAddress
                    draftEnvironment = result.detectedEnvironment
                }
            } catch let error as AppError {
                await MainActor.run {
                    geocodingState = .failure(error)
                }
            } catch {
                await MainActor.run {
                    geocodingState = .failure(.geocodingFailed)
                }
            }
        }
    }


    func saveAnchor(context: ModelContext) {
        guard !draftTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let coordinate = locationManager.userLocation
            ?? region.center

        let anchor = AnchorItem(
            title: draftTitle,
            note: draftNote,
            coordinate: coordinate,
            tag: draftTag,
            mood: draftMood,
            environment: draftEnvironment
        )
        anchor.resolvedAddress = draftAutoAddress

        context.insert(anchor)

        flowState = .map
        centerOn(anchor)
        showToast("⚓ \(anchor.title) anchored!")
        resetDraft()
    }

  

    func delete(_ anchor: AnchorItem, context: ModelContext) {
        context.delete(anchor)
        if case .detail(let a) = flowState, a.id == anchor.id {
            flowState = .map
        }
        showToast("Anchor removed")
    }

  

    func markVisit(_ anchor: AnchorItem) {
        anchor.visitCount += 1
        showToast("Visit #\(anchor.visitCount) recorded! +score")
    }


    private func resetDraft() {
        draftTitle       = ""
        draftNote        = ""
        draftTag         = .memory
        draftMood        = .neutral
        draftEnvironment = .unknown
        draftAutoAddress = nil
        geocodingState   = .idle
    }

    private func showError(_ error: AppError) {
        currentError   = error
        showErrorAlert = true
    }

    func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            await MainActor.run { toastMessage = nil }
        }
    }
}


enum StatSortOrder: String, CaseIterable {
    case score    = "Score"
    case visits   = "Visits"
    case recent   = "Recent"
    case grade    = "Grade"
}
