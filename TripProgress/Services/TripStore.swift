import Foundation

final class TripStore {
    private let key = "lastTripSession"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ session: TripSession?) {
        guard let session else {
            defaults.removeObject(forKey: key)
            return
        }

        if let data = try? JSONEncoder().encode(session) {
            defaults.set(data, forKey: key)
        }
    }

    func load() -> TripSession? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(TripSession.self, from: data)
    }
}
