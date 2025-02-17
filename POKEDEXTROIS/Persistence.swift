import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "POKEDEXTROIS")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error.localizedDescription)")
            }
        }
    }
}
