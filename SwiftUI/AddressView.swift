//
//  AddressView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 1/2/22.
//  Copyright © 2022 Michael Rowe. All rights reserved.
//  

import SwiftUI

struct AddressView: View {
    var recipient: Recipient
    private var iPhone = false

    init(recipient: Recipient) {
        self.recipient = recipient
        if UIDevice.current.userInterfaceIdiom == .phone {
            iPhone = true
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(recipient.wrappedFirstName)
                Text(recipient.wrappedLastName)
            }
            if let addressLine1 = recipient.addressLine1, !addressLine1.isEmpty {
                Text(addressLine1)
            }
            if let addressLine2 = recipient.addressLine2, !addressLine2.isEmpty {
                Text(addressLine2)
            }
            let cityLine =
                (recipient.city.map {"\($0), "} ?? "") +
                (recipient.state.map {"\($0) "} ?? "") +
                (recipient.zip ?? "")
            if cityLine != ",  " {
                Text(cityLine)
            }

            if let countryLine = recipient.country, !countryLine.isEmpty {
                Text(countryLine).textCase(.uppercase)
            }
        }
        .scaledToFit()
        .foregroundColor(.accentColor)
        .padding([.leading, .trailing], 10 )
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(recipient: Recipient())
    }
}
