import CoreData

public class CoreDataStoreMaker {
    
    public static func makeInMemoryStore(closure: (ModelBuilder) -> ()) -> (NSPersistentStoreCoordinator, NSManagedObjectContext) {
        let mb = ModelBuilder()
        
        closure(mb)
        
        //: Create the in-memory persistent store coordinator for the model
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mb.model)
        
        try! psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        
        //: Create the main context
        
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        
        return (psc, moc)
    }
    
}
