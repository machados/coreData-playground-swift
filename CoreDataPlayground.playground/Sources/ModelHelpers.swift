import CoreData

public protocol ModelEntity: class {
    static var entityName: String { get }
    typealias Attributes: RawRepresentable
    typealias Relationships: RawRepresentable
    static func entity(builder: ModelBuilder) -> EntityBuilder
}
/*
extension ModelEntity where Self: NSManagedObject {
    public static func entityWithProperties(properties: [NSAttributeDescription]) -> NSEntityDescription {
        let ed = NSEntityDescription()
        ed.name = Self.entityName
        ed.managedObjectClassName = Self.entityName
        ed.properties = properties
        return ed
    }
}

extension ModelEntity where Self: NSManagedObject, AttributeKeys.RawValue == String {
    public static func stringAttributeWithKey(key: AttributeKeys, optional: Bool = true, indexed: Bool = false) -> NSAttributeDescription {
        return Self.attributeWithKey(key, type: .StringAttributeType, optional: optional, indexed: indexed)
    }
    private static func attributeWithKey(key: AttributeKeys, type: NSAttributeType, optional: Bool = true, indexed: Bool = false) -> NSAttributeDescription {
        let ad = NSAttributeDescription()
        ad.name = key.rawValue
        ad.attributeType = type
        ad.optional = optional
        ad.indexed = indexed
        return ad
    }
}*/

public class EntityBuilder {
    let entity: NSEntityDescription
    init(name: String) {
        entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = name
    }
    public func string(name: String, optional: Bool = true, indexed: Bool = false) -> EntityBuilder {
        return attribute(name, type: .StringAttributeType, optional: optional, indexed: indexed)
    }
    private func attribute(name: String, type: NSAttributeType, optional: Bool = true, indexed: Bool = false) -> EntityBuilder {
        let ad = NSAttributeDescription()
        ad.name = name
        ad.attributeType = type
        ad.optional = optional
        ad.indexed = indexed
        entity.properties.append(ad)
        return self
    }
    public func oneToMany(manyEntity: EntityBuilder, oneName: String, manyName: String) -> EntityBuilder {
        let one = NSRelationshipDescription()
        let many = NSRelationshipDescription()
        
        many.name = manyName
        many.destinationEntity = manyEntity.entity
        many.minCount = 0
        many.maxCount = 0
        many.deleteRule = NSDeleteRule.CascadeDeleteRule
        many.inverseRelationship = one
        
        one.name = oneName
        one.destinationEntity = self.entity
        one.minCount = 0
        one.maxCount = 1
        one.deleteRule = NSDeleteRule.NullifyDeleteRule
        one.inverseRelationship = many
        
        entity.properties.append(many)
        manyEntity.entity.properties.append(one)
        
        return self
    }
}

public class ModelBuilder {
    
    let model: NSManagedObjectModel
    
    init() {
        model = NSManagedObjectModel()
    }
    
    public func entity(name: String) -> EntityBuilder {
        let eb = EntityBuilder(name: name)
        model.entities.append(eb.entity)
        return eb
    }
    
    public func oneToMany(oneEntity: EntityBuilder, manyEntity: EntityBuilder) -> ModelBuilder {
        
        return self
    }
    
}