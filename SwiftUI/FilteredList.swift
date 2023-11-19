//
//  FilteredList.swift
//  Card Tracker
//
//  Created by Michael Rowe on 3/6/22.
//  Copyright © 2022 Michael Rowe. All rights reserved.
//

import SwiftUI
import CoreData

struct FilteredList: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var recipients: FetchedResults<Recipient>
    @FetchRequest var events: FetchedResults<Event>
    private var eventList = false

    static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    init(filter: String, eventList: Bool) {
        self.eventList = eventList
        if filter.isEmpty {
            _recipients = FetchRequest<Recipient>(
                sortDescriptors: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)]
            )
            _events = FetchRequest<Event>(
                sortDescriptors: [SortDescriptor(\.event)]
            )
        } else {
            // c = lower case
            // d = diacritic-insensitive for example - (ignore ü and just use u)
            _recipients = FetchRequest<Recipient>(
                sortDescriptors: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)],
                predicate: NSPredicate(format: "lastName CONTAINS[cd] %@ OR firstName CONTAINS[cd] %@", filter, filter)
            )
            _events = FetchRequest<Event>(
                sortDescriptors: [SortDescriptor(\.event)],
                predicate: NSPredicate(format: "event CONTAINS[cd] %@", filter)
            )
        }
    }

    var body: some View {
        List {
            if eventList {
                ForEach(events, id: \.self) { event in
                    Section(event.recipient?.fullName ?? "Unknown") {
                        ForEach(event.recipient?.eventArray ?? [], id: \.self) { eventName in
                            NavigationLink(destination:
                                            ViewAnEventView(event: event, recipient: event.recipient!)) {
                                // swiftlint:disable line_length
                                Text("\(eventName.wrappedEvent) \(eventName.wrappedEventDate, formatter: FilteredList.eventDateFormatter)")
                                    .foregroundColor(Color(red: 0.138, green: 0.545, blue: 0.282))
                            }
                        }

                    }
                }
            } else {
                ForEach(recipients, id: \.self) { recipient in
                    NavigationLink(destination:
                                    ViewEventsView(recipient: recipient)) {
                        Text("\(recipient.wrappedFirstName) \(recipient.wrappedLastName)")
                            .foregroundColor(Color(red: 0.138, green: 0.545, blue: 0.282))
                    }
                }
                .onDelete(perform: deleteRecipient)
            }
        }
    }

    func deleteRecipient(offsets: IndexSet) {

        for index in offsets {
            let recipient = recipients[index]
            moc.delete(recipient)
        }
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
