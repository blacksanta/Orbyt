import Foundation
import HerdrKit

/// Carries a bigtty install over to Orbyt, once: its settings (saved
/// machines, sessions, window frames) from the old bundle id's defaults,
/// and its support folder (pane state, extensions). Cookies and the
/// notification permission stay with the old id.
enum LegacyMigration {
    private static let doneKey = "migratedFromBigtty"
    private static let oldIDs = ["dev.orbyt.orbyt": "dev.bigtty.bigtty", "dev.orbyt.dev": "dev.bigtty.dev"]

    static func run() {
        moveSupportFolder()
        copyDefaults()
    }

    private static func copyDefaults() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: doneKey),
              let id = Bundle.main.bundleIdentifier, let oldID = oldIDs[id]
        else { return }
        // Only keys Orbyt hasn't set itself, so a second run can't undo a change.
        let old = defaults.persistentDomain(forName: oldID) ?? [:]
        let current = defaults.persistentDomain(forName: id) ?? [:]
        for (key, value) in old where current[key] == nil {
            defaults.set(value, forKey: key)
        }
        defaults.set(true, forKey: doneKey)
    }

    private static func moveSupportFolder() {
        let fm = FileManager.default
        let new = BigttyControl.supportFolder
        let old = new.deletingLastPathComponent().appendingPathComponent("bigtty", isDirectory: true)
        guard fm.fileExists(atPath: old.path), !fm.fileExists(atPath: new.path) else { return }
        do {
            try fm.moveItem(at: old, to: new)
            // The old app's socket, not ours.
            try? fm.removeItem(at: new.appendingPathComponent("control.sock"))
        } catch {
            NSLog("Orbyt: could not move \(old.path): \(error)")
        }
    }
}
