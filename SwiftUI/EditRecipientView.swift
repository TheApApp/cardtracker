//
//  EditRecipientView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 2/28/21.
//  Copyright © 2021 Michael Rowe. All rights reserved.
//

import os
import SwiftUI

struct EditRecipientView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode

    private let borderWidth: CGFloat = 1.0

    var recipient: Recipient

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zip: String = ""
    @State private var country: String = ""

    @State private var showHome: Bool = false

    init(recipient: Recipient) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 35)!]
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 20)!]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance

        self.recipient = recipient
        self._firstName = State(initialValue: recipient.firstName ?? "")
        self._lastName = State(initialValue: recipient.lastName ?? "")
        self._addressLine1 = State(initialValue: recipient.addressLine1 ?? "")
        self._addressLine2 = State(initialValue: recipient.addressLine2 ?? "")
        self._city = State(initialValue: recipient.city ?? "")
        self._state = State(initialValue: recipient.state ?? "")
        self._zip = State(initialValue: recipient.zip ?? "")
        self._country = State(initialValue: recipient.country ?? "")
    }

    var body: some View {
        NavigationView {
            GeometryReader { geomtry in
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            TextField("First Name", text: $firstName)
                            .customTextField()
                        }
                        VStack(alignment: .leading) {
                            TextField("Last Name", text: $lastName)
                                .customTextField()
                        }
                    }
                    TextField("Address Line 1", text: $addressLine1)
                        .customTextField()
                    TextField("Address Line 2", text: $addressLine2)
                        .customTextField()
                    HStack {
                        TextField("City", text: $city)
                            .customTextField()
                            .frame(width: geomtry.size.width * 0.48)
                        Spacer()
                        TextField("ST", text: $state)
                            .customTextField()
                            .frame(width: geomtry.size.width * 0.18)
                        Spacer()
                        TextField("Zip", text: $zip)
                            .customTextField()
                            .frame(width: geomtry.size.width * 0.28)
                    }
                    TextField("Country", text: $country)
                        .customTextField()
                    Spacer()
                    Spacer()
                }
            }
            .padding([.leading, .trailing], 10)
            .navigationBarTitle("\(recipient.firstName ?? "no first name") \(recipient.lastName ?? "no last name")")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: {
                        saveRecipient(
                            recipient: recipient,
                            firstName: firstName,
                            lastName: lastName,
                            addLine1: addressLine1,
                            addLine2: addressLine2,
                            city: city,
                            state: state,
                            zip: zip,
                            country: country)
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                            .foregroundColor(.green)
                    })
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    })
                }
            }
        }
    }
}

// swiftlint:disable:next function_parameter_count
func saveRecipient(
    recipient: Recipient,
    firstName: String,
    lastName: String,
    addLine1: String,
    addLine2: String,
    city: String,
    state: String,
    zip: String,
    country: String) {

    let logger=Logger(subsystem: "com.theapapp.christmascardtracker", category: "EditRecipient.SaveRecipient")
    let context = PersistentCloudKitContainer.persistentContainer.viewContext
    recipient.firstName = firstName
    recipient.lastName  = lastName
    recipient.addressLine1 = addLine1
    recipient.addressLine2 = addLine2
    recipient.city = city
    recipient.state = state
    recipient.zip = zip
    recipient.country = country

    do {
        try context.save()
    } catch {
        logger.log("Error during Save ... \(error.localizedDescription)")
    }
}
struct EditRecipientView_Previews: PreviewProvider {
    static var previews: some View {
        EditRecipientView(recipient: Recipient())
    }
}
