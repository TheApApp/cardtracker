//
//  VIewEventsView.swift
//  HolidayCardTracker
//
//  Created by Michael Rowe on 12/30/20.
//

import os
import SwiftUI
import CoreData
import MapKit

enum NavBarItemChoosen: Identifiable {
    case newCard // , editRecipient, deleteCard
    var id: Int {
        hashValue
    }
}

struct ViewEventsView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest private var events: FetchedResults<Event>

    private var blankCardFront = UIImage(contentsOfFile: "frontImage")
    private var recipient: Recipient
    @State private var isEditActive: Bool = false
    @State private var isCardActive: Bool = false
    @State private var areYouSure: Bool = false

    @State var newEvent = false
    @State var frontView = false
    @State var frontShown = true
    @State private var frontImageShown: UIImage?

    @State private var actionSheetPresented = false
    @State var navBarItemChoosen: NavBarItemChoosen?
    private var gridLayout: [GridItem]
    @State var isEditing = false
    @State var num: Int = 0
    private var deviceiPhone = false

    @State var region: MKCoordinateRegion?

    static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    init(recipient: Recipient) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 35)!
        ]
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
            .font: UIFont(name: "ArialRoundedMTBold", size: 20)!
        ]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        self.recipient = recipient
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Event.eventDate, ascending: false),
            NSSortDescriptor(keyPath: \Event.event, ascending: true)
        ]
        request.predicate =  NSPredicate(format: "%K == %@", #keyPath(Event.recipient), recipient)
        _events = FetchRequest<Event>(fetchRequest: request)
        if UIDevice.current.userInterfaceIdiom != .phone {
            self.gridLayout = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
        } else {
            deviceiPhone = true
            self.gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
        }
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    if let region = region {
                        MapView(region: region)
                            .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.2)
                            .mask(RoundedRectangle(cornerRadius: 25))
                            .padding([.top, .leading], 15 )
                        AddressView(recipient: recipient)
                    }
                    Spacer()
                        .onAppear {
                            // swiftlint:disable:next line_length
                            let addressString = String("\(recipient.addressLine1 ?? "") \(recipient.city ?? "") \(recipient.state ?? "") \(recipient.zip ?? "") \(recipient.country ?? "")")
                            getLocation(from: addressString) { coordinates in
                                if let coordinates = coordinates {
                                    // swiftlint:disable:next line_length
                                    self.region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                                }
                            }
                        }
                }
                ScrollView {
                    LazyVGrid(columns: gridLayout, alignment: .center, spacing: 1) {
                        ForEach(events, id: \.self) { event in
                            HStack {
                                VStack {
                                    Image(uiImage: (event.cardFrontImage ?? blankCardFront)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(.top, deviceiPhone ? 5: 15)
                                    HStack {
                                        VStack {
                                            Text("\(event.event ?? "")")
                                            // swiftlint:disable:next line_length
                                            Text("\(event.eventDate ?? NSDate(), formatter: ViewEventsView.eventDateFormatter)")
                                        }
                                        .padding(deviceiPhone ? 5 : 15)
                                        .font(deviceiPhone ? .caption : .title2)
                                        .foregroundColor(.primary)
                                        VStack {
                                            MenuOverlayView(recipient: recipient, event: event)
                                                .padding(deviceiPhone ? 5: 15)
                                        }
                                    }
                                }
                            }
                            // swiftlint:disable:next line_length
                            .frame(width: deviceiPhone ? geo.size.width * 0.5 : geo.size.width * 0.3, height: deviceiPhone ? geo.size.width * 0.5 : geo.size.width * 0.3)
                            .background(Color(UIColor.systemGroupedBackground))
                            .mask(RoundedRectangle(cornerRadius: 20))
                            .padding(15)
                        }
                    }
                }
                .navigationTitle("\(recipient.firstName ?? "no first name") \(recipient.lastName ?? "no last name")")
                .navigationBarItems(trailing:
                                        HStack {
                    Button(action: {
                        navBarItemChoosen = .newCard
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    })

                })
            }
            .sheet(item: $navBarItemChoosen ) { item in
                switch item {
                case .newCard:
                    AddNewCardView(recipient: recipient)
                }
            }
        }
        .accentColor(.green)
    }

    private func deleteEvent(event: Event) {
        let logger=Logger(subsystem: "com.theapapp.christmascardtracker", category: "ViewEventsView.DeleteEvent")
        let taskContext = moc
        taskContext.perform {
            taskContext.delete(event)
            do {
                try taskContext.save()
            } catch {
                let nsError = error as NSError
                logger.log("Unresolved error \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func getLocation(from address: String, completion: @escaping (_ location: CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, _) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(location)
        }
    }
}

struct ViewEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ViewEventsView(recipient: Recipient())
    }
}
