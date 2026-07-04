import Foundation

enum TripProgressCalculator {
    static func completedFraction(totalDistance: CLLocationDistance, remainingDistance: CLLocationDistance) -> Double {
        guard totalDistance > 0 else { return 0 }

        let traveled = max(totalDistance - remainingDistance, 0)
        let fraction = traveled / totalDistance
        return min(max(fraction, 0), 1)
    }

    static func displayedFraction(
        totalDistance: CLLocationDistance,
        remainingDistance: CLLocationDistance,
        mode: TripDisplayMode
    ) -> Double {
        let progress = completedFraction(totalDistance: totalDistance, remainingDistance: remainingDistance)

        switch mode {
        case .progress:
            return progress
        case .countdown:
            return 1 - progress
        }
    }

    static func displayedPercent(
        totalDistance: CLLocationDistance,
        remainingDistance: CLLocationDistance,
        mode: TripDisplayMode
    ) -> Int {
        Int((displayedFraction(totalDistance: totalDistance, remainingDistance: remainingDistance, mode: mode) * 100).rounded())
    }
}
