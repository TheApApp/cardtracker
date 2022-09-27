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
    @FetchRequest var fetchRequest: FetchedResults<Recipient>

    init(filter: String) {
        if filter.isEmpty {
            _fetchRequest = FetchRequest<Recipient>(
                sortDescriptors: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)]
            )
        } else {
            _fetchRequest = FetchRequest<Recipient>(
                sortDescriptors: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)],
                predicate: NSPredicate(format: "lastName CONTAINS[c] %@", filter)
            )
        }
    }

    var body: some View {
        List {
            ForEach(fetchRequest, id: \.self) { recipient in
                NavigationLink(destination:
                                ViewEventsView(recipient: recipient)) {
                    Text("\(recipient.wrappedFirstName) \(recipient.wrappedLastName)")
                        .foregroundColor(.green)
                }
            }
            .onDelete(perform: deleteRecipient)
        }
    }

    func deleteRecipient(offsets: IndexSet) {

        for index in offsets {
            let recipient = fetchRequest[index]
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
