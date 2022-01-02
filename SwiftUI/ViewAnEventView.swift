//
//  ViewAnEventView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 12/26/20.
//  Copyright © 2020 Michael Rowe. All rights reserved.
//

import SwiftUI

struct ViewAnEventView: View {
    enum NavBarItemChoosen: Identifiable {
        case editEvent
        var id: Int {
            hashValue
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @State private var zoomed = false

    private var event: Event
    private var recipient: Recipient

    private var blankCardFront = UIImage(contentsOfFile: "frontImage")

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
        let navBarApperance = UINavigationBarAppearance()
        navBarApperance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 35)!
        ]
        navBarApperance.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 15)!
        ]

        UINavigationBar.appearance().standardAppearance = navBarApperance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarApperance
        UINavigationBar.appearance().compactAppearance = navBarApperance
        self.recipient = recipient
        self.event = event
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(event.event ?? "no event")-\(event.eventDate!, formatter: Self.eventDateFormatter)")
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1.0)
                Spacer()
                Button(action: {
                    showCardView = .edit
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title)
                        .foregroundColor(.green)
                })
            }
            .padding([.leading, .trailing], 10 )
            HStack {
                Button( action: {
                    showCardView = .front
                }, label: {
                    Image(uiImage: (event.cardFrontImage ?? blankCardFront)!)
                        .resizable()
                        .aspectRatio(contentMode: zoomed ? .fill : .fit)
                })
            }
            Spacer()
                .sheet(item: $showCardView) { item in
                    switch item {
                    case .front:
                        // swiftlint:disable:next line_length
                        CardView(cardImage: (event.cardFrontImage ?? blankCardFront)!, event: event.event ?? "", eventDate: event.eventDate! as Date)
                    case .edit:
                        EditAnEvent(event: event, recipient: recipient)
                    }
                }
        }
    }
}

struct ViewAnEventView_Previews: PreviewProvider {
    static var previews: some View {
        ViewAnEventView(event: Event(), recipient: Recipient())
    }
}
