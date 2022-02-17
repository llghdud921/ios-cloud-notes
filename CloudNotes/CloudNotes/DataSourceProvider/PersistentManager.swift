import CoreData

class PersistentManager {
    static let shared = PersistentManager()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "CloudNotes")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError()
            }
        }

        return container
    }()

    private lazy var context: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()

    func fetch<T>(request: NSFetchRequest<T>, predicate: NSPredicate? = nil) throws -> [T] {
        if let predicate = predicate {
            request.predicate = predicate
        }

        let data = try self.context.fetch(request)
        return data
    }

    func create(entityName: String, values: [String: Any]) {
        let context = self.context
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)

        if let entity = entity {
            let content = NSManagedObject(entity: entity, insertInto: context)
            values.forEach { (key, value) in
                content.setValue(value, forKey: key)
            }
        }

        self.saveContext()
    }

    func update(object: NSManagedObject, values: [String: Any]) {
        values.forEach { (key, value) in
            object.setValue(value, forKey: key)

        }

        self.saveContext()
    }

    func delete(object: NSManagedObject) {
        context.delete(object)
        self.saveContext()
    }

    func saveContext() {
        if self.context.hasChanges {
            do {
                try self.context.save()
            } catch {
                let nserror = error as NSError
                fatalError("\(nserror)")
            }
        }
    }
}
