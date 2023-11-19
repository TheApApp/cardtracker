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

enum NavBarItemChosen: Identifiable {
    case newCard // , editRecipient, deleteCard
    var id: Int {
        hashValue
    }
}

struct ViewEventsView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest private var events: FetchedResults<Event>
    
    private let blankCardFront = UIImage(contentsOfFile: "frontImage")
    private var recipient: Recipient
    @State private var isEditActive: Bool = false
    @State private var isCardActive: Bool = false
    @State private var areYouSure: Bool = false
    
    @State var newEvent = false
    @State var frontView = false
    @State var frontShown = true
    @State private var frontImageShown: UIImage?
    
    @State private var actionSheetPresented = false
    @State var navBarItemChosen: NavBarItemChosen?
    private var gridLayout: [GridItem]
    @State var isEditing = false
    @State var num: Int = 0
    private var iPhone = false
    
    @State var region: MKCoordinateRegion?
    
    static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    // MARK: PDF Properties
    @State var PDFUrl: URL?
    @State var showShareSheet: Bool = false
    
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.gridLayout = [
                GridItem(.adaptive(minimum: 320), spacing: 20, alignment: .center)
            ]
        } else {
            iPhone = true
            self.gridLayout = [
                GridItem(.adaptive(minimum: 160), spacing: 10, alignment: .center)
            ]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    if let region = region {
                        MapView(region: region)
                            .frame(width: iPhone ? 120 : 200, height: 150)
                            .mask(RoundedRectangle(cornerRadius: 25))
                            .padding([.top, .leading], 15 )
                        AddressView(recipient: recipient)
                            .scaledToFit()
                            .frame(width: 250, height: 150)
                    }
                    Spacer()
                        .onAppear {
                            // swiftlint:disable:next line_length
                            let addressString = String("\(recipient.addressLine1 ?? "") \(recipient.city ?? "") \(recipient.state ?? "") \(recipient.zip ?? "") \(recipient.country ?? "")")
                            getLocation(from: addressString) { coordinates in
                                if let coordinates = coordinates {
                                    self.region = MKCoordinateRegion(
                                        center: coordinates,
                                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                                }
                            }
                        }
                }
                ScrollView {
                    LazyVGrid(columns: gridLayout, alignment: .center, spacing: 5) {
                        ForEach(events, id: \.self) { event in
                            HStack {
                                VStack {
                                    Image(uiImage: (event.cardFrontImage ?? blankCardFront)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .scaledToFit()
                                        .frame(width: iPhone ? 120 : 200, height: iPhone ? 120 : 200)
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
                        .padding()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                                        HStack {
                    Button(action: {
                        navBarItemChosen = .newCard
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    })
                    Button(action: {
                        // MARK: self is Current View
                        // You can give whatever View to Conver
                        //                        print(convertToScrollView(content: {
                        //                            self
                        //                        }).contentSize)
                        exportPDF { self } completion: { status, url in
                            if let url = url, status {
                                print("Button Pressed for \(url)")
                                PDFUrl = url
                                showShareSheet.toggle()
                            } else {
                                print("Failed to Produce PDF")
                            }
                        }
                    }, label: {
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    })
                })
            }
            .sheet(item: $navBarItemChosen ) { item in
                switch item {
                case .newCard:
                    AddNewCardView(recipient: recipient)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                PDFUrl = nil
            } content: {
                if let PDFUrl = PDFUrl {
                    ShareSheet(urls: [PDFUrl])
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

// MARK: Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var urls: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
