import Foundation

final class PredicationVault {

    static let sovereign = PredicationVault()

    private let persistenceVault = UserDefaults.standard

    private static let resonanceKey = "nd_resonance_enabled"
    private static let sonorusKey = "nd_sonorus_enabled"

    private init() {
        if persistenceVault.object(forKey: PredicationVault.resonanceKey) == nil {
            persistenceVault.set(true, forKey: PredicationVault.resonanceKey)
        }
        if persistenceVault.object(forKey: PredicationVault.sonorusKey) == nil {
            persistenceVault.set(true, forKey: PredicationVault.sonorusKey)
        }
    }

    var isResonanceEnabled: Bool {
        get { persistenceVault.bool(forKey: PredicationVault.resonanceKey) }
        set { persistenceVault.set(newValue, forKey: PredicationVault.resonanceKey) }
    }

    var isSonorusEnabled: Bool {
        get { persistenceVault.bool(forKey: PredicationVault.sonorusKey) }
        set { persistenceVault.set(newValue, forKey: PredicationVault.sonorusKey) }
    }

    func expungeAllApexRecords() {
        TallyLedger.sovereign.purgeAllRecords()
    }
}
