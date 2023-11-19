//
//  EditAnEvent.swift
//  Card Tracker
//
//  Created by Michael Rowe on 12/22/21.
//  Copyright © 2021 Michael Rowe. All rights reserved.
//

import os
import SwiftUI

struct EditAnEvent: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode

    var event: Event
    var recipient: Recipient
    var defaultImage = UIImage(named: "frontImage")

    @State private var cardFrontImage: Image?
    @State var frontImageSelected: Image?
    @State private var eventName: String
    @State private var firstName: String
    @State private var lastName: String
    @State private var eventDate: Date
    @State private var selectedEvent: Int
    @State var frontPhoto = false
    @State var captureFrontImage = false
    @State var shouldPresentCamera = false

    init(event: Event, recipient: Recipient) {
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
        self.event = event
        self.recipient = recipient
        self._firstName = State(initialValue: recipient.firstName ?? "")
        self._lastName = State(initialValue: recipient.lastName ?? "")
        self._cardFrontImage = State(initialValue: Image(uiImage: event.cardFrontImage ?? defaultImage!))
        self._frontImageSelected = State(initialValue: Image(uiImage: event.cardFrontImage!))
        self._eventDate = State(initialValue: event.eventDate! as Date)
        self._eventName = State(initialValue: event.event ?? "")
        self._selectedEvent = State(initialValue: eventChoices.firstIndex(of: event.event ?? "Anniversary")!)
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Text("Event")
                    Spacer()
                    Picker(selection: $selectedEvent, label: Text("")) {
                        ForEach(0 ..< eventChoices.count, id: \.self) {
                            Text(eventChoices[$0])
                        }
                    }
                    .frame(width: geo.size.width * 0.55, height: geo.size.height * 0.25)
                }
                .padding([.leading, .trailing], 10)
                DatePicker(
                    "Event Date",
                    selection: $eventDate,
                    displayedComponents: [.date])
                .padding([.leading, .trailing, .bottom], 10)
                HStack {
                    ZStack {
                        frontImageSelected?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: 10 )
                        VStack {
                            Image(systemName: "camera.fill")
                            Text("Front")
                        }
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .shadow(radius: 10)
                        .frame(width: geo.size.width * 0.45)
                        .onTapGesture { self.frontPhoto = true }
                        .actionSheet(isPresented: $frontPhoto) { () -> ActionSheet in
                            ActionSheet(
                                title: Text("Choose mode"),
                                message: Text("Select one."),
                                buttons: [ActionSheet.Button.default(Text("Camera"), action: {
                                    self.captureFrontImage.toggle()
                                    self.shouldPresentCamera = true
                                }),
                                          ActionSheet.Button.default(Text("Photo Library"), action: {
                                              self.captureFrontImage.toggle()
                                              self.shouldPresentCamera = false
                                          }),
                                          ActionSheet.Button.cancel()])
                        }
                        .sheet(isPresented: $captureFrontImage) {
                            ImagePicker(
                                sourceType: self.shouldPresentCamera ? .camera : .photoLibrary,
                                image: $frontImageSelected,
                                isPresented: self.$captureFrontImage)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding([.leading, .trailing], 10)
        .navigationBarTitle(
            "\(recipient.firstName ?? "no first name") \(recipient.lastName ?? "no last name")",
                            displayMode: .inline
        )
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: {
                    saveCard()
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

    func saveCard() {
        let logger=Logger(subsystem: "com.theapapp.christmascardtracker", category: "EditAnEvent.saveCard")
        logger.log("saving event... \(eventName)")
        event.event = eventChoices[selectedEvent]
        event.eventDate = eventDate as NSDate
        ImageCompressor.compress(image: (frontImageSelected?.asUIImage())!, maxByte: 2_000_000) { image in
            guard image != nil else {
                logger.log("Error compressing image")
                return
            }
            event.cardFrontImage = image
            event.recipient = recipient
            do {
                logger.log("Saved \(event)")
                try moc.save()
            } catch let error as NSError {
                logger.log("Save error \(error), \(error.userInfo)")
            }
        }
    }
}

struct EditAnEvent_Previews: PreviewProvider {
    static var previews: some View {
        EditAnEvent(event: Event(), recipient: Recipient())
    }
}
