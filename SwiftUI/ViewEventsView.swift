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
        print("Events = \(_events)")
        
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
        //        ScrollView {
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
                                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
                            }
                        }
                    }
            }
            ScrollView {
                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 5) {
                    ForEach(events, id: \.self) { event in
                        GridView(recipient: recipient, event: event, printView: false)
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
                ShareLink("Export PDF", item: render(viewsPerPage: 15))
                
            })
        }
        .sheet(item: $navBarItemChosen ) { item in
            switch item {
            case .newCard:
                AddNewCardView(recipient: recipient)
            }
        }
        .accentColor(.green)
    }
    
    @MainActor func render(viewsPerPage: Int) -> URL {
        let eventsArray: [Event] = events.map { $0 }
        let url = URL.documentsDirectory.appending(path: "\(recipient.wrappedFirstName)-\(recipient.wrappedLastName)-cards.pdf")
        var pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        guard let pdf = CGContext(url as CFURL, mediaBox: &pageSize, nil) else {
            return url
        }
        
        let numberOfPages = Int((events.count + viewsPerPage - 1) / viewsPerPage)   // Round to number of pages
        let viewsPerRow = 4
        let rowsPerPage = 5
        let viewWidth = 143.0   // Page Width (612) / viewsPerRow (4) - Spacing (10)
        let viewHeight = 148.4  // Page Height (792) / rowesPerPage (5) - Spacing (10)
        let spacing = 10.0
        var header = CGSize(width: 0.0, height: 0.0)
        var loop = 0
        
        for pageIndex in 0..<numberOfPages {
            pdf.beginPDFPage(nil)
            
            let rendererTop = ImageRenderer(content: AddressView(recipient: recipient).frame(maxWidth: .infinity).scaledToFit())
            rendererTop.render { size, context in
                let xTranslation = 0.0 // pageSize.size.width / 2 - size.width / 2
                let yTranslation = pageSize.size.height - size.height - spacing // Adjusted y-translation
                pdf.translateBy(
                    x: xTranslation - min(max(CGFloat(pageIndex) * xTranslation, 0), xTranslation),
                    y: yTranslation
                )
                context(pdf)
                print("\n\nStarting page = \(pageIndex)")
                print("Address Size is width = \(size.width); height = \(size.height) -- Position x= \(xTranslation - min(max(CGFloat(pageIndex) * xTranslation, 0), xTranslation)) / y = \(yTranslation) for pageIndex = \(pageIndex)")
                header = size
            }
            
            let startIndex = pageIndex * viewsPerPage
            let endIndex = min(startIndex + viewsPerPage, eventsArray.count)
            
            for row in 0..<rowsPerPage {
                var yTranslation = (CGFloat(row) * (viewHeight + spacing)) + spacing + header.height
                
                for col in 0..<viewsPerRow {
                    let index = startIndex + row * viewsPerRow + col
                    if index < endIndex, let event = eventsArray[safe: index] {
                        let xTranslation = CGFloat(col) * (viewWidth + spacing)
                        
                        let renderer = ImageRenderer(content: GridView(recipient: recipient, event: event, printView: true).frame(width: viewWidth, height: viewHeight).scaledToFit())
                        renderer.render { size, context in
                            pdf.translateBy(
                                x: xTranslation,
                                y: 692 - yTranslation
                            )
                            context(pdf)
                            print("Event \(index) is width = \(size.width); height = \(size.height) -- Position x= \(xTranslation) / y = \(692 - yTranslation)")
                        }
                    }
                }
            }
            
            let rendererBottom = ImageRenderer(content: Text("Page \(pageIndex + 1)"))
            rendererBottom.render { size, context in
                let xTranslation = 295.0 // pageSize.size.width / 2 - size.width / 2
                let yTranslation = 0.0 // Adjusted y-translation
                pdf.translateBy(
                    x: xTranslation - min(max(CGFloat(pageIndex) * xTranslation, 0), xTranslation),
                    y: yTranslation
                )
                context(pdf)
                print("\nEnding page = \(pageIndex)")
            }
            
            pdf.endPDFPage()
        }
        
        pdf.closePDF()
        return url
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
