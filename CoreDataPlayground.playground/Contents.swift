//: ## Programmatic model creation

import UIKit
import CoreData
import Foundation
import XCPlayground

//: Access the playground helper sources
import CoreDataPlayground_Sources

//: Entity Classes
//:
//: Entity classes need to be annotated with @objc and subclasses of NSManagedObject

@objc(Employee)
final class Employee: NSManagedObject, ModelEntity {
    @NSManaged var name: String
    @NSManaged var company: Company?
    
    static let entityName = "Employee"
    enum Attributes: String {
        case name = "name"
    }
    enum Relationships: String {
        case company = "company"
    }
    
    static func entity(builder: ModelBuilder) -> EntityBuilder {
        return
            builder
                .entity(entityName)
                .string(Attributes.name.rawValue, optional: false, indexed: true)
    }
    
}

@objc(Company)
final class Company: NSManagedObject, ModelEntity {
    @NSManaged var name: String
    @NSManaged var employees: Set<Employee>
    
    static let entityName = "Company"
    enum Attributes: String {
        case name = "name"
    }
    enum Relationships: String {
        case employees = "employees"
    }
    
    static func entity(builder: ModelBuilder) -> EntityBuilder {
        return
            builder
                .entity(entityName)
                .string(Attributes.name.rawValue, optional: false, indexed: true)
    }
    
}

//: Create the model

let (psc, moc) = CoreDataStoreMaker.makeInMemoryStore { builder in
    
    Company.entity(builder).oneToMany(Employee.entity(builder),
        oneName: Employee.Relationships.company.rawValue,
        manyName: Company.Relationships.employees.rawValue)
    
}

//: Setup a class to listen for context notifications

final class NotificationListener: NSObject {
    func handleDidSaveNotification(notification: NSNotification) {
        print("\(__FUNCTION__): \(notification)")
    }
}

let notificationDelegate = NotificationListener()
NSNotificationCenter.defaultCenter().addObserver(notificationDelegate, selector: "handleDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil)

//: Add managed objects

var company = NSEntityDescription.insertNewObjectForEntityForName(Company.entityName, inManagedObjectContext: moc) as! Company

//: Set a value using KVO:
//:
//: `company.setValue("ACME", forKey: Company.Attributes.name.rawValue)`
//:
//: Or using the NSManagedObject subclass, since we defined one:

company.name = "ACME"

var employee = NSEntityDescription.insertNewObjectForEntityForName(Employee.entityName, inManagedObjectContext: moc) as! Employee

employee.name = "John"
employee.company = company

//: Persist the data

try! moc.save()

//: Fetch the data

let fetchRequest = NSFetchRequest(entityName: Employee.entityName)
let results = try! moc.executeFetchRequest(fetchRequest)

results.count

let emp = results[0] as! Employee
emp.name
emp.company?.name
