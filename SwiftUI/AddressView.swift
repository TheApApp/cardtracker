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
    private var deviceiPhone = false

    init(recipient: Recipient) {
        self.recipient = recipient
        if UIDevice.current.userInterfaceIdiom == .phone {
            deviceiPhone = true
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let addressLine1 = recipient.addressLine1, !addressLine1.isEmpty {
                Text(addressLine1)
            }
            if let addressLine2 = recipient.addressLine2, !addressLine2.isEmpty {
                Text(addressLine2)
            }
            // swiftlint:disable:next line_length
            let cityLine = (recipient.city.map {"\($0), "} ?? "") + (recipient.state.map {"\($0) "} ?? "") + (recipient.zip ?? "")
            if cityLine != ",  " {
                Text(cityLine)
            }

            if let countryLine = recipient.country, !countryLine.isEmpty {
                Text(countryLine)
            }
        }
        .font(deviceiPhone ? .title2 : .title)
        .foregroundColor(.green)
        .padding([.leading, .trailing], 10 )
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(recipient: Recipient())
    }
}
