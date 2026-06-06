import Foundation
import CoreLocation

/// Driver-side GPS broadcaster. Mirrors the webApp's
/// `navigator.geolocation.watchPosition` block in `delivery-dashboard.ftlh:360`
/// (the M5 broadcast fix).
///
/// Posts the driver's current lat/lng to `POST /api/deliveries/location`
/// while the driver has at least one ACCEPTED or IN_DELIVERY package.
@MainActor
final class LocationBroadcaster: NSObject, ObservableObject {
    enum Status { case idle, requestingPermission, broadcasting, denied, unavailable }

    @Published private(set) var status: Status = .idle
    @Published private(set) var lastError: String?

    private let manager = CLLocationManager()
    private var enabled = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 25 // metres
    }

    /// Start (or stop) broadcasting based on whether the driver has active packages.
    func setEnabled(_ on: Bool) {
        guard on != enabled else { return }
        enabled = on
        if on {
            switch manager.authorizationStatus {
            case .notDetermined:
                status = .requestingPermission
                manager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                start()
            case .denied, .restricted:
                status = .denied
            @unknown default:
                status = .unavailable
            }
        } else {
            stop()
        }
    }

    private func start() {
        status = .broadcasting
        manager.startUpdatingLocation()
    }

    private func stop() {
        manager.stopUpdatingLocation()
        status = .idle
    }
}

extension LocationBroadcaster: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                if self.enabled { self.start() }
            case .denied, .restricted:
                self.status = .denied
            case .notDetermined:
                self.status = .requestingPermission
            @unknown default:
                self.status = .unavailable
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        Task { [weak self] in
            do {
                try await APIClient.shared.requestVoid(
                    .updateDriverLocation,
                    method: .post,
                    body: UpdateLocationRequest(latitude: coord.latitude, longitude: coord.longitude)
                )
            } catch {
                await MainActor.run { self?.lastError = error.localizedDescription }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.lastError = error.localizedDescription
        }
    }
}
