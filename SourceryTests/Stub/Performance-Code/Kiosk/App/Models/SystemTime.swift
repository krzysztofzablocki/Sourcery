import Foundation
import RxSwift

class SystemTime {
    var systemTimeInterval: TimeInterval? = nil

    init () {}

    func sync(_ provider: Networking) -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.systemTime

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .doOnNext { [weak self] response in
                guard let dictionary = response as? NSDictionary else { return }

                let timestamp: String = (dictionary["iso8601"] as? String) ?? ""
                if let artsyDate = KioskDateFormatter.fromString(timestamp) {
                    self?.systemTimeInterval = Date().timeIntervalSince(artsyDate)
                }

            }.logError().map(void)
    }

    func inSync() -> Bool {
        return systemTimeInterval != nil
    }

    func date() -> Date {
        let now = Date()
        if let systemTimeInterval = systemTimeInterval {
            return now.addingTimeInterval(-systemTimeInterval)
        } else {
            return now
        }
    }

    func reset() {
        systemTimeInterval = nil
    }
}
