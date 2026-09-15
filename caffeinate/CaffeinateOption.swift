import Foundation

enum CaffeinateOption: String, CaseIterable {
    case display
    case idle
    case disk
    case system

    var flag: String {
        switch self {
        case .display: return "-d"
        case .idle: return "-i"
        case .disk: return "-m"
        case .system: return "-s"
        }
    }

    var title: String {
        switch self {
        case .display: return String(localized: "Prevent display sleep")
        case .idle: return String(localized: "Prevent system idle sleep")
        case .disk: return String(localized: "Prevent disk idle sleep")
        case .system: return String(localized: "Prevent system sleep (on AC power)")
        }
    }
}
