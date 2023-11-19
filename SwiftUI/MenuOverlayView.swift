//
//  MenuOverlayView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 4/16/22.
//  Copyright © 2022 Michael Rowe. All rights reserved.
//

import os
import SwiftUI

struct MenuOverlayView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode

    @State var areYouSure: Bool = false
    @State var isEditActive: Bool = false
    @State var isCardActive: Bool = false

    private let blankCardFront = UIImage(contentsOfFile: "frontImage")
    private var iPhone = false
    private var event: Event
    private var recipient: Recipient

    init(recipient: Recipient, event: Event) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            iPhone = true
        }
        self.recipient = recipient
        self.event = event
    }

    var body: some View {
        HStack {
            Spacer()
            NavigationLink {
                EditAnEvent(event: event, recipient: recipient)
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.green)
                    .font(iPhone ? .caption : .title3)
            }
            NavigationLink {
                CardView(
                    cardImage: (event.cardFrontImage ?? blankCardFront)!,
                    event: event.wrappedEvent,
                    eventDate: event.wrappedEventDate as Date)
            } label: {
                Image(systemName: "doc.text.image")
                    .foregroundColor(.green)
                    .font(iPhone ? .caption : .title3)
            }
            Button(action: {
                areYouSure.toggle()
            }, label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(iPhone ? .caption : .title3)
            })
            .confirmationDialog("Are you Sure", isPresented: $areYouSure, titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    withAnimation {
                        print("Deleting Event \(event.wrappedEvent) \(event.wrappedEventDate)")
                        deleteEvent(event: event)
                    }
                }
                Button("No") {
                    withAnimation {
                        print("Cancelled delete of \(event.wrappedEvent) \(event.wrappedEventDate)")
                    }
                } .keyboardShortcut(.defaultAction)
            }
        }
    }

    private func deleteEvent(event: Event) {
        let logger=Logger(subsystem: "com.theapapp.christmascardtracker", category: "MenuOverlayView.deleteEvent")
        let taskContext = moc
        taskContext.perform {
            taskContext.delete(event)
            do {
                try taskContext.save()
            } catch {
                let nsError = error as NSError
                logger.log("Unresolved error \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
