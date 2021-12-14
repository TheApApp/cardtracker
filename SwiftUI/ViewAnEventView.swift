//
//  ViewAnEventView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 12/26/20.
//  Copyright © 2020 Michael Rowe. All rights reserved.
//

import SwiftUI

struct ViewAnEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var zoomed = false

    private var event: Event
    private var recipient: Recipient

    private var blankCardFront = UIImage(contentsOfFile: "frontImage")
    private var blankCardBack = UIImage(contentsOfFile: "backImage")

    enum ShowCardView: Identifiable {
        case front, back
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
            .font: UIFont(name: "ArialRoundedMTBold", size: 20)!
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
                AddressView(recipient: recipient)
                Spacer()
            }
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
                        CardView(cardImage: (event.cardFrontImage ?? blankCardFront)!)
                    case .back:
                        CardView(cardImage: (event.cardBackImage ?? blankCardBack)!)
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

struct AddressView: View {
    var recipient: Recipient

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(recipient.addressLine1 ?? "")")
                .padding([.top], 10)
                .foregroundColor(.green)
            if recipient.addressLine2 != "" {
                Text("\(recipient.addressLine2 ?? "")")
                    .foregroundColor(.green)
            }
            Text("\(recipient.city ?? ""), \(recipient.state ?? "") \(recipient.zip ?? "")")
                .foregroundColor(.green)
            Text("\(recipient.country ?? "")")
                .foregroundColor(.green)
        }
        .padding([.leading, .trailing], 10 )
    }
}
