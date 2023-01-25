//
//  Recipient+CoreDataProperties.swift
//  Card Tracker
//
//  Created by Michael Rowe on 3/16/18.
//  Copyright © 2018 Michael Rowe. All rights reserved.
//
//

import Foundation
import CoreData

extension Recipient: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipient> {
        return NSFetchRequest<Recipient>(entityName: "Recipient")
    }

    @NSManaged public var addressLine1: String?
    @NSManaged public var addressLine2: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var state: String?
    @NSManaged public var zip: String?
    @NSManaged public var events: NSSet?
    @NSManaged public var id: UUID?

    var wrappedFirstName: String {
        firstName ?? "Unknown"
    }

    var wrappedLastName: String {
        lastName ?? "Unknown"
    }
    
    var fullName: String {
        String("\(firstName) \(lastName)")
    }

}

// MARK: Generated accessors for events
extension Recipient {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}
