import Foundation
import os

@MainActor
final class CaffeinateController {
    private static let executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
    private static let optionsKey = "SelectedOptions"

    private let defaults: UserDefaults
    private var process: Process?

    private(set) var options: Set<CaffeinateOption> {
        didSet { defaults.set(options.map(\.rawValue), forKey: Self.optionsKey) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let stored = defaults.array(forKey: Self.optionsKey) as? [String] {
            options = Set(stored.compactMap(CaffeinateOption.init(rawValue:)))
        } else {
            options = [.display, .idle]
        }
    }

    func isEnabled(_ option: CaffeinateOption) -> Bool {
        options.contains(option)
    }

    func toggle(_ option: CaffeinateOption) {
        if options.contains(option) {
            options.remove(option)
        } else {
            options.insert(option)
        }
        start()
    }

    func start() {
        let wasRunning = process != nil
        terminateProcess()

        let flags = CaffeinateOption.allCases.filter(options.contains).map(\.flag)
        let dieWithThisApp = ["-w", String(ProcessInfo.processInfo.processIdentifier)]

        let process = Process()
        process.executableURL = Self.executableURL
        process.arguments = flags + dieWithThisApp

        do {
            try process.run()
            self.process = process
            let described = flags.isEmpty ? "no flags (idle sleep)" : flags.joined(separator: " ")
            Logger.app.info("caffeinate started with \(described, privacy: .public)")
        } catch {
            Logger.app.error("Failed to start caffeinate: \(error.localizedDescription, privacy: .public)")
            return
        }

        if !wasRunning {
            Notifier.post(.started)
        }
    }

    func stop() {
        let wasRunning = process != nil
        terminateProcess()

        if wasRunning {
            Notifier.post(.stopped, waitForDelivery: true)
        }
    }

    private func terminateProcess() {
        if let process, process.isRunning {
            process.terminate()
            Logger.app.info("caffeinate stopped")
        }
        process = nil
    }
}
