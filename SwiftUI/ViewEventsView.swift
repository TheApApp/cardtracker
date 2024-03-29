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
                        ScreenView(recipient: recipient, event: event)
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
                ShareLink("Export PDF", item: render(viewsPerPage: 16))
                
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
        
        guard let pdfOutput = CGContext(url as CFURL, mediaBox: &pageSize, nil) else {
            return url
        }
        
        let numberOfPages = Int((events.count + viewsPerPage - 1) / viewsPerPage)   // Round to number of pages
        let viewsPerRow = 4
        let rowsPerPage = 4
        let spacing = 10.0
        
        for pageIndex in 0..<numberOfPages {
            let startIndex = pageIndex * viewsPerPage
            let endIndex = min(startIndex + viewsPerPage, eventsArray.count)
            
            var currentX : Double = 0
            var currentY : Double = 0
            
            pdfOutput.beginPDFPage(nil)
            
            // Printer header - top 160 points of the page
            let renderTop = ImageRenderer(content: AddressView(recipient: recipient))
            renderTop.render { size, renderTop in
                // Go to Bottom Left of Page and then translate up to 160 points from the top
                pdfOutput.move(to: CGPoint(x: 0.0, y: 0.0))
                pdfOutput.translateBy(x: 0.0, y: 692)
                currentY += 692
                renderTop(pdfOutput)
            }
            pdfOutput.translateBy(x: spacing / 2, y: -160)
            
            for row in 0..<rowsPerPage {
                for col in 0..<viewsPerRow {
                    let index = startIndex + row * viewsPerRow + col
                    if index < endIndex, let event = eventsArray[safe: index] {
                        let renderBody = ImageRenderer(content: PrintView(event: event))
                        renderBody.render { size, renderBody in
                            renderBody(pdfOutput)
                            pdfOutput.translateBy(x: size.width + 10, y: 0)
                            currentX += size.width + 10
                        }
                        print("Body - currentX = \(currentX), currentY = \(currentY)")
                    }
                }
                pdfOutput.translateBy(x: -pageSize.width + 5, y: -144)
                currentY -= 153
                currentX = 0
            }
            
            // Print Footer - from bottom of page, up 40 points
            let renderBottom = ImageRenderer(content: FooterView(page: pageIndex + 1, pages: numberOfPages))
            pdfOutput.move(to: CGPoint(x: 0, y: 0))
            pdfOutput.translateBy(x: 0, y: 40)
            renderBottom.render { size, renderBottom in
                renderBottom(pdfOutput)
            }
            pdfOutput.endPDFPage()
        }
        pdfOutput.closePDF()
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

#Preview {
    ViewEventsView(recipient: Recipient())
}
