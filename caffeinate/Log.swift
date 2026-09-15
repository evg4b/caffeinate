import Foundation
import os

extension Logger {
    static let app = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Caffeinate", category: "app")
}
