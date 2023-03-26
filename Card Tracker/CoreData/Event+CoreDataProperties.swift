//
//  Event+CoreDataProperties.swift
//  Card Tracker
//
//  Created by Michael Rowe on 3/16/18.
//  Copyright © 2018 Michael Rowe. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData

extension Event: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var cardFrontThumbnailURI: String?
    @NSManaged public var cardFrontImage: UIImage?
    @NSManaged public var cardFrontThumbnailImage: UIImage?
    @NSManaged public var cardFrontURI: String?
    @NSManaged public var event: String?
    @NSManaged public var eventDate: NSDate?
    @NSManaged public var recipient: Recipient?
    @NSManaged public var id: UUID?

    public var wrappedEvent: String {
        event ?? "Unknown Event"
    }

    public var wrappedEventDate: NSDate {
        eventDate ?? Date() as NSDate
    }
    
}
