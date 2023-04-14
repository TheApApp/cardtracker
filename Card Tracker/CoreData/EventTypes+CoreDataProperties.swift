//
//  EventTypes+CoreDataProperties.swift
//  Card Tracker
//
//  Created by Michael Rowe on 4/2/23.
//  Copyright © 2023 Michael Rowe. All rights reserved.
//
//

import Foundation
import CoreData

extension EventTypes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventTypes> {
        return NSFetchRequest<EventTypes>(entityName: "EventTypes")
    }

    @NSManaged public var eventName: String?
    @NSManaged public var events: NSSet?

    public var unwrappedEventName: String {
        eventName ?? "Unknown Event"
    }
}

// MARK: Generated accessors for events
extension EventTypes {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

extension EventTypes: Identifiable {

}
