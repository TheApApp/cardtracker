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
    private var recipient: Recipient
    @State var newEvent = false
    @State var frontView = false
    @State var backView = false
    @State var frontShown = true
    @State private var frontImageShown: UIImage?
    @State var navBarItemChoosen: NavBarItemChoosen?

    // swiftlint:disable:next line_length
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
        GeometryReader { _ in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        if let region = region {
                            MapView(region: region)
                                .frame(width: 300, height: 250)
                                .padding([.leading, .trailing], 10 )
                        }

                        if let addressLine1 = recipient.addressLine1, !addressLine1.isEmpty {
                            Text(addressLine1)
                        }
                        if let addressLine2 = recipient.addressLine2, !addressLine2.isEmpty {
                            Text(addressLine2)
                        }
                        
                        let cityLine = recipient.city.map { "\($0)," } ?? ""
                        + (recipient.state ?? "")
                        + (recipient.zip ?? "")
                        if !cityLine.isEmpty {
                            Text(cityLine)
                        }
                        
                        if let countryLine = recipient.country, !countryLine.isEmpty {
                            Text(countryLine)
                        }
                    }
                    .padding(10)
                    .foregroundColor(.green)
                    .onAppear {
                        // swiftlint:disable:next line_length
                        let addressString = String("\(recipient.addressLine1 ?? "") \(recipient.city ?? "") \(recipient.state ?? "") \(recipient.zip ?? "") \(recipient.country ?? "")")
                        getLocation(from: addressString) { coordinates in

                            if let coordinates = coordinates {
                                print("\(recipient.addressLine1 ?? "") \(recipient.city ?? "") \(recipient.state ?? "") \(recipient.zip ?? "") \(recipient.country ?? "")")
                                
                                self.region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                            }
                        }
                    }
                }


                List {
                    ForEach(events, id: \.self) { event in
                        NavigationLink(destination: ViewAnEventView(event: event, recipient: recipient)) {
                            HStack {
                                VStack {
                                    Spacer()
                                    Text("\(event.event ?? "Unknown Event")")
                                        .font(.title)
                                        .foregroundColor(.green)
                                    Text("\(event.eventDate!, formatter: Self.eventDateFormatter)")
                                        .font(.title)
                                        .foregroundColor(.green)
                                    Spacer()
                                }
                                Spacer()
                                if event.cardFrontImage != nil {
                                    Image(uiImage: (event.cardFrontImage ?? UIImage(contentsOfFile: "frontImage"))!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image("frontImage")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            } .frame(height: 300)
                        }
                    }
                    .onDelete(perform: deleteEvent)
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
