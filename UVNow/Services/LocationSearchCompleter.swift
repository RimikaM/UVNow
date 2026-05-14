import MapKit
import Observation

@MainActor
@Observable
final class LocationSearchCompleter: NSObject {

    var suggestions: [MKLocalSearchCompletion] = []
    var query: String = "" {
        didSet { completer.queryFragment = query }
    }

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }
}

extension LocationSearchCompleter: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        MainActor.assumeIsolated {
            self.suggestions = self.completer.results
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        MainActor.assumeIsolated {
            self.suggestions = []
        }
    }
}
