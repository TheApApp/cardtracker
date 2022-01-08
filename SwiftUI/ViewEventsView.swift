//
//  VIewEventsView.swift
//  HolidayCardTracker
//
//  Created by Michael Rowe on 12/30/20.
//

import SwiftUI
import CoreData
import MapKit

enum NavBarItemChoosen: Identifiable {
    case newCard, editRecipient
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

    @State var newEvent = false
    @State var frontView = false
    @State var backView = false
    @State var frontShown = true
    @State private var frontImageShown: UIImage?
    @State var navBarItemChoosen: NavBarItemChoosen?
    @State var gridLayout: [GridItem] = [ GridItem()]

    @State var region: MKCoordinateRegion?

    static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    init(recipient: Recipient) {
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
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Event.eventDate, ascending: false),
            NSSortDescriptor(keyPath: \Event.event, ascending: true)
        ]
        request.predicate =  NSPredicate(format: "%K == %@", #keyPath(Event.recipient), recipient)
        _events = FetchRequest<Event>(fetchRequest: request)
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    if let region = region {
                        MapView(region: region)
                            .frame(width: geo.size.width * 0.3, height: geo.size.height * 0.2)
                            .padding([.leading, .trailing], 10 )
                    }
                    AddressView(recipient: recipient)
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
                            NavigationLink(destination: ViewAnEventView(event: event, recipient: recipient)) {
                                HStack {
                                    VStack {
                                        ZStack {
                                            Spacer()
                                            Image(uiImage: (event.cardFrontImage ?? blankCardFront)!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .ignoresSafeArea(edges: [.vertical, .bottom])
                                            HStack {
                                                VStack {
                                                    Spacer()
                                                    Text("\(event.event ?? "")")
                                                    // swiftlint:disable:next line_length
                                                    Text("\(event.eventDate ?? NSDate(), formatter: ViewEventsView.eventDateFormatter)")
                                                    Spacer()
                                                }
                                                .padding(10)
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .shadow(color: .black, radius: 2.0)
                                            }
                                        }
                                    }
                                } .frame(height: geo.size.width * 0.3)
                            }
                        }
                        .onDelete(perform: deleteEvent)
                        // systemname: "trash.circle"
                    }
                }
                .navigationTitle("\(recipient.firstName ?? "no first name") \(recipient.lastName ?? "no last name")")
                .navigationBarItems(trailing:
                                        HStack {
                    Button(action: {
                        navBarItemChoosen = .newCard
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                    })
                    Button(action: {
                        navBarItemChoosen = .editRecipient
                    }, label: {
                        Image(systemName: "square.and.pencil")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                    })
                    Button(action: {
                        self.gridLayout = Array(repeating: .init(.flexible()), count: self.gridLayout.count % 4 + 1)
                    }, label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.title)
                            .foregroundColor(.green)
                    })
                })
            }
            .sheet(item: $navBarItemChoosen ) { item in
                switch item {
                case .newCard:
                    AddNewCardView(recipient: recipient)
                case .editRecipient:
                    EditRecipientView(recipient: recipient)
                }
            }
        }
    }

    private func deleteEvent(offsets: IndexSet) {
        withAnimation {
            offsets.map { events[$0] }.forEach(moc.delete)
            do {
                try moc.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                let nsError = error as NSError
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
