//
//  AddNewCardView.swift
//  Card Tracker
//
//  Created by Michael Rowe on 1/1/21.
//  Copyright © 2021 Michael Rowe. All rights reserved.
//

import SwiftUI

struct AddNewCardView: View {
    var recipient: Recipient
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode

    private var eventChoices = [
        "Anniversary",
        "Bereavement",
        "Birthday",
        "Bon Voyage",
        "Bridal Shower",
        "Chanukah",
        "Christmas",
        "Congratulations",
        "Divorce",
        "Easter",
        "Engagement",
        "Father’s Day",
        "Flag Day",
        "Fourth of July",
        "Friendship",
        "Get Well",
        "Graduation",
        "Halloween",
        "Kwanza",
        "Love",
        "Mother’s Day",
        "New Baby",
        "New Home",
        "Passover",
        "Sorry",
        "St. Patrick’s Day",
        "St. Valentine’s Day",
        "Sympathy",
        "Thank you",
        "Thanksgiving",
        "Thinking of You",
        "Wedding"
    ]
    private var eventValue = "Anniversary"

    @State private var zoomed = false

    enum CaptureCardView: Identifiable {
        case front, back
        var id: Int {
            hashValue
        }
    }

    @State var captureCardView: CaptureCardView?
    @State private var selectedEvent = 0
    @State private var eventDate = Date()
    @State var frontImageSelected: Image? = Image("frontImage")
    @State var backImageSelected: Image? = Image("backImage")
    @State var shouldPresentCamera = false
    @State var frontPhoto = false
    @State var backPhoto = false
    @State var captureFrontImage = false
    @State var captureBackImage = false

    init(recipient: Recipient) {
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
        self.recipient = recipient
    }

    var body: some View {
        NavigationView {
            GeometryReader { geomtry in
                VStack {
                    HStack {
                        Text("Event")
                        Spacer()
                        Picker(selection: $selectedEvent, label: Text("")) {
                            ForEach(0 ..< eventChoices.count) {
                                Text(self.eventChoices[$0])
                            }
                        }
                        .frame(width: geomtry.size.width * 0.55, height: geomtry.size.height * 0.25)
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
                            .frame(width: geomtry.size.width * 0.45)
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
            .navigationBarTitle("\(recipient.firstName ?? "no first name") \(recipient.lastName ?? "no last name")")
            .navigationBarItems(trailing:
                                    HStack {
                Button(action: {
                    saveCard()
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

    func saveCard() {
        print("saving...")
        let event = Event(context: moc)
        event.event = eventChoices[selectedEvent]
        event.eventDate = eventDate as NSDate
        event.cardFrontImage = frontImageSelected?.asUIImage()
        event.cardBackImage = backImageSelected?.asUIImage()
        event.recipient = recipient
        do {
            print(event)
            try moc.save()
        } catch let error as NSError {
            print("Save error \(error), \(error.userInfo)")
        }
    }
}

extension View {
    // This function changes our View to UIView, then calls another function
    // to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)

        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
//        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows.first!.rootViewController?.view.addSubview(controller.view)

        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()

        // here is the call to the function that converts UIView to UIImage: `.asImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
    // This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

struct AddNewCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewCardView(
            recipient: Recipient()).environment(\.managedObjectContext,
                                                 PersistentCloudKitContainer.persistentContainer.viewContext)
    }
}
