//
//  AddNewRecipientView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 1/1/21.
//  Copyright © 2021 Michael Rowe. All rights reserved.
//

import SwiftUI
import SwiftUIKit
import ContactsUI
import Contacts
import CoreData

struct AddNewRecipientView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode

    private let borderWidth: CGFloat = 1.0

    @State private var lastName: String = ""
    @State private var firstName: String = ""
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zip: String = ""
    @State private var country: String = ""

    @State var showPicker = false

    init() {
        let navBarApperance = UINavigationBarAppearance()
        navBarApperance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 35)!]
        navBarApperance.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 20)!]
        UINavigationBar.appearance().standardAppearance = navBarApperance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarApperance
        UINavigationBar.appearance().compactAppearance = navBarApperance
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
                ContactPicker(showPicker: $showPicker, onSelectContact: {contact in
                    firstName = contact.givenName
                    lastName = contact.familyName
                    if contact.postalAddresses.count > 0 {
                        if let addressString = (
                            ((contact.postalAddresses[0] as AnyObject).value(forKey: "labelValuePair")
                                as AnyObject).value(forKey: "value"))
                            as? CNPostalAddress {
                            // swiftlint:disable:next line_length
                            let mailAddress = CNPostalAddressFormatter.string(from: addressString, style: .mailingAddress)
                            addressLine1 = "\(addressString.street)"
                            addressLine2 = ""
                            city = "\(addressString.city)"
                            state = "\(addressString.state)"
                            zip = "\(addressString.postalCode)"
                            country = "\(addressString.country)"
                            print(mailAddress)
                        }
                    } else {
                        addressLine1 = "No Address Provided"
                        addressLine2 = ""
                        city = ""
                        state = ""
                        zip = ""
                        country = ""
                        print("No Address Provided")
                    }
                    self.showPicker.toggle()
                }, onCancel: nil)
            }
            .padding([.leading, .trailing], 10 )
            .navigationTitle("Recipient")
            .navigationBarItems(trailing:
                                    HStack {
                                        Button(action: {
                                            let contactsPermsissions = checkContactsPermissions()
                                            if contactsPermsissions == true {
                                                self.showPicker.toggle()
                                            }
                                        }, label: {
                                            Image(systemName: "magnifyingglass")
                                                .font(.largeTitle)
                                                .foregroundColor(.green)
                                        })
                                        Button(action: {
                                            saveRecipient()
                                            self.presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            Image(systemName: "square.and.arrow.down")
                                                .font(.largeTitle)
                                                .foregroundColor(.green)
                                        })
                                        Button(action: {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            Image(systemName: "chevron.down.circle.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(.green)
                                        })
                                    }
            )
        }
    }

    func saveRecipient() {
        print("Saving...")
        if firstName != "" {
            let recipient = Recipient(context: self.moc)
            recipient.firstName = firstName
            recipient.lastName = lastName
            recipient.addressLine1 = addressLine1.capitalized(with: NSLocale.current)
            recipient.addressLine2 = addressLine2.capitalized(with: NSLocale.current)
            recipient.state = state.uppercased()
            recipient.city = city.capitalized(with: NSLocale.current)
            recipient.zip = zip
            recipient.country = country.capitalized(with: NSLocale.current)
        }
        do {
            try moc.save()
        } catch let error as NSError {
            print("Save error: \(error), \(error.userInfo)")
        }
    }

    func checkContactsPermissions() -> Bool {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authStatus {
        case .restricted:
            print("User cannot grant premission, e.g. perental controls are in force.")
            return false
        case .denied:
            print("User has denided permissions")
            // add a popup to say you have denied permissions
            return false
        case .notDetermined:
            print("you need to request authorization via the API now")
        case .authorized:
            print("already authorized")
        @unknown default:
            print("unknown error")
            return false
        }
        let store = CNContactStore()
        if authStatus == .notDetermined {
            store.requestAccess(for: .contacts) {success, error in
                if !success {
                    print("Not authorized to access contacts. Error = \(String(describing: error))")
                    exit(1)
                }
                print("Authorized")
            }
        }
        return true
    }
}

struct AddNewRecipientView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewRecipientView()
            .environment(\.managedObjectContext, PersistentCloudKitContainer.persistentContainer.viewContext)
    }
}
