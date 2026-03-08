import Foundation

final class TallyLedger {

    static let sovereign = TallyLedger()

    private let persistenceVault = UserDefaults.standard

    private init() {}

    func adjudicateApex(candidateScore: Int, variant: ArenaVariant = .classicEndurance) -> Bool {
        let currentApex = persistenceVault.integer(forKey: variant.persistenceKey)
        if candidateScore > currentApex {
            persistenceVault.set(candidateScore, forKey: variant.persistenceKey)
            return true
        }
        return false
    }

    func retrieveApexScore(variant: ArenaVariant = .classicEndurance) -> Int {
        return persistenceVault.integer(forKey: variant.persistenceKey)
    }

    func purgeAllRecords() {
        for variant in [ArenaVariant.classicEndurance, ArenaVariant.chronoSprint] {
            persistenceVault.set(0, forKey: variant.persistenceKey)
        }
    }
}
