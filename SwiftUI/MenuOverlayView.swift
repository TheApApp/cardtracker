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

    private var blankCardFront = UIImage(contentsOfFile: "frontImage")
    private var deviceiPhone = false
    private var event: Event
    private var recipient: Recipient

    init(recipient: Recipient, event: Event) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            deviceiPhone = true
        }
        self.recipient = recipient
        self.event = event
    }

    var body: some View {
        HStack {
            Spacer()
            // swiftlint:disable:next line_length
            NavigationLink(destination: EditAnEvent(event: event, recipient: recipient), isActive: $isEditActive, label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.green)
                    .font(deviceiPhone ? .body : .title3)
            })
            .padding(deviceiPhone ? 1 : 4)
            NavigationLink(destination: CardView(
                cardImage: (event.cardFrontImage ?? blankCardFront)!,
                event: event.event ?? "Unknown Event",
                eventDate: event.eventDate! as Date),
                           isActive: $isCardActive, label: {
                Image(systemName: "doc.text.image")
                    .foregroundColor(.green)
                    .font(deviceiPhone ? .body : .title3)
            })
            .padding(deviceiPhone ? 1 : 4)
            Button(action: {
                areYouSure.toggle()
            }, label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(deviceiPhone ? .body : .title3)
                    .padding(deviceiPhone ? 1 : 4)
            })
            .confirmationDialog("Are you Sure", isPresented: $areYouSure, titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    withAnimation {
                        // swiftlint:disable:next line_length
                        print("Deleting Event \(String(describing: event.event)) \(String(describing: event.eventDate))")
                        deleteEvent(event: event)
                    }
                }
                Button("No") {
                    withAnimation {
                        // swiftlint:disable:next line_length
                        print("Cancelled delete of \(String(describing: event.event)) \(String(describing: event.eventDate))")
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
