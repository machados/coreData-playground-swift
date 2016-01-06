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
class Employee: NSManagedObject, ModelEntity {
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
    
    // Better description for Employee
    override var description: String {
        return "Employee: \(self.name)"
    }
    
}

//: CRUD
extension Employee {
    static func createWithName(
        name: String,
        andCompany company: Company,
        inContext context: NSManagedObjectContext) -> Employee {
            
        let employee = NSEntityDescription.insertNewObjectForEntityForName(Employee.entityName, inManagedObjectContext: context) as! Employee
        
        employee.name = name
        employee.company = company
        return employee
    }
}

@objc(Company)
class Company: NSManagedObject, ModelEntity {
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
    
    // Better description for Company
    override var description: String {
        return "Company: \(self.name)"
    }
}

//: CRUD
extension Company {
    static func createWithName(name: String, inContext context: NSManagedObjectContext) -> Company {
        let company = NSEntityDescription.insertNewObjectForEntityForName(Company.entityName, inManagedObjectContext: moc) as! Company
        company.name = name
        return company
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

let company = Company.createWithName("ACME", inContext: moc)

Employee.createWithName("John", andCompany: company, inContext: moc)
Employee.createWithName("Paul", andCompany: company, inContext: moc)

//: Persist the data

try! moc.save()

//: Fetch the data

var fetchRequest = NSFetchRequest(entityName: Employee.entityName)
var results = try! moc.executeFetchRequest(fetchRequest)

results.count

let emp = results[0] as! Employee
emp.name
emp.company?.name

//: To get a company employees, simply access the managed object property

print(company.employees)

//: [Next](@next)