//
//  ViewAnEventView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 12/26/20.
//  Copyright © 2020 Michael Rowe. All rights reserved.
//
// Deprecated view - should remove this one

import SwiftUI

struct ViewAnEventView: View {
    enum NavBarItemChoosen: Identifiable {
        case editEvent
        var id: Int {
            hashValue
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @State private var zoomed = false

    private var event: Event
    private var recipient: Recipient

    private let blankCardFront = UIImage(contentsOfFile: "frontImage")

    @State var navBarItemChoosen: NavBarItemChoosen?

    enum ShowCardView: Identifiable {
        case front, edit
        var id: Int {
            hashValue
        }
    }
    @State var showCardView: ShowCardView?

    static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    init(event: Event, recipient: Recipient) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 35)!
        ]
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 15)!
        ]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        self.recipient = recipient
        self.event = event
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(event.event ?? "no event") - \(event.eventDate!, formatter: Self.eventDateFormatter)")
                    .font(.title)
                    .foregroundColor(.green)
                Spacer()
                Button(action: {
                    showCardView = .edit
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title)
                        .foregroundColor(.green)
                })
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                    deleteCard(event: event)
                } label: {
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
            .padding([.leading, .trailing], 5 )
            Image(uiImage: (event.cardFrontImage ?? blankCardFront)!)
            .resizable()
            .aspectRatio(contentMode: zoomed ? .fill : .fit)
            Spacer()
                .sheet(item: $showCardView) { item in
                    switch item {
                    case .front:
                        CardView(
                            cardImage: (event.cardFrontImage ?? blankCardFront)!,
                            event: event.event ?? "",
                            eventDate: event.eventDate! as Date
                        )
                    case .edit:
                        EditAnEvent(event: event, recipient: recipient)
                    }
                }
        }
    }

    func deleteCard(event: Event) {
        print("Delete the card \(event)")
        moc.delete(event)
        // how do we trigger removal from the prior screen's 
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ViewAnEventView_Previews: PreviewProvider {
    static var previews: some View {
        ViewAnEventView(event: Event(), recipient: Recipient())
    }
}
