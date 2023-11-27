//
//  ScreenView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 11/23/23.
//  Copyright © 2023 Michael Rowe. All rights reserved.
//

import CoreData
import SwiftUI

struct ScreenView: View {
    private let blankCardFront = UIImage(contentsOfFile: "frontImage")
    private var recipient: Recipient
    private var iPhone = false
    private var event: Event
    
    init(recipient: Recipient, event: Event) {
        self.recipient = recipient
        self.event = event
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            iPhone = false
        } else {
            iPhone = true
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(uiImage: (event.cardFrontImage ?? blankCardFront)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iPhone ? 120 : 225, height: iPhone ? 120 : 225)
                    .scaledToFit()
                    .padding(.top, iPhone ? 2: 5)
                HStack {
                    VStack {
                        Text("\(event.event ?? "")")
                            .foregroundColor(.green)
                        Spacer()
                        HStack {
                            // swiftlint:disable:next line_length
                            Text("\(event.wrappedEventDate, formatter: ViewEventsView.eventDateFormatter)")
                                .fixedSize()
                                .foregroundColor(.green)
                            MenuOverlayView(recipient: recipient, event: event)
                        }
                    }
                    .padding(iPhone ? 1 : 5)
                    .font(iPhone ? .caption : .title3)
                    .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .frame(minWidth: iPhone ? 160 : 320, maxWidth: .infinity,
               minHeight: iPhone ? 160 : 320, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .mask(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
        .padding(iPhone ? 5: 10)
    }
}

#Preview {
    ScreenView(recipient: Recipient(), event: Event())
}
