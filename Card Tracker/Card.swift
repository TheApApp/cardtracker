//
//  Card.swift
//  Card Tracker
//
//  Created by Michael Rowe on 2/17/18.
//  Copyright © 2018 Michael Rowe. All rights reserved.
//

import UIKit

class Recipient {

    var firstName = ""
    var lastName = ""
    var addressLine1 = ""
    var addressLine2 = ""
    var city = ""
    var state = ""
    var zip = ""
    var country = ""
    var eventCard: [Event ] = []
}

class Event {
    var event = ""
    var eventDate = ""
    var cardFront = UIImage()
    var cardBack = UIImage()
}
