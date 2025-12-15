import Foundation

@MainActor
public class AppVersionTracker {
    public static let shared = AppVersionTracker()
    
    private let defaults: UserDefaults
    private let versionKey = "com.appversion.currentVersion"
    private let historyKey = "com.appversion.history"
    
    public private(set) var currentVersion: String
    public private(set) var previousVersion: String?
    public private(set) var history: [String]
    
    public var isFirstLaunch: Bool {
        return history.isEmpty
    }
    
    public var isUpgrade: Bool {
        guard let previous = previousVersion else { return false }
        return currentVersion != previous
    }
    
    init(userDefaults: UserDefaults = .standard, bundle: Bundle = .main, currentVersion: String? = nil) {
        self.defaults = userDefaults
        self.currentVersion = currentVersion ?? bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        self.previousVersion = userDefaults.string(forKey: versionKey)
        self.history = userDefaults.stringArray(forKey: historyKey) ?? []
    }
    
    public func track() {
        if history.isEmpty {
            // First launch ever
            history.append(currentVersion)
            defaults.set(currentVersion, forKey: versionKey)
            defaults.set(history, forKey: historyKey)
        } else if let lastVersion = history.last, lastVersion != currentVersion {
            // Upgrade or change
            previousVersion = lastVersion
            history.append(currentVersion)
            defaults.set(currentVersion, forKey: versionKey)
            defaults.set(history, forKey: historyKey)
        }
        // If same version, do nothing
    }
}
