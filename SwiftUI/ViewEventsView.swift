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
        var box = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
            return url
        }
        
        let numberOfPages = (events.count + viewsPerPage - 1) / viewsPerPage
        let viewsPerRow = 3
        let rowsPerPage = 5
        let viewWidth: CGFloat = (box.width - CGFloat(viewsPerRow - 1) * 10) / CGFloat(viewsPerRow)
        let viewHeight: CGFloat = (box.height - CGFloat(rowsPerPage - 1) * 10 ) / CGFloat(viewsPerPage)
        let spacing: CGFloat = 10
        
        for pageIndex in 0..<numberOfPages {
            pdf.beginPDFPage(nil)
            
            let rendererTop = ImageRenderer(content: AddressView(recipient: recipient).frame(maxWidth: .infinity).scaledToFit())
            rendererTop.render { size, context in
                let xTranslation = box.size.width / 2 - size.width / 2
                let yTranslation = box.size.height - size.height - spacing // Adjusted y-translation
                print("Position for address is x= \(xTranslation) / y = \(yTranslation)")
                print("Size is \(size)")
                pdf.translateBy(
                    x: xTranslation - min(max(CGFloat(pageIndex) * xTranslation, 0), xTranslation),
                    y: yTranslation
                )
                context(pdf)
            }
            
            let startIndex = pageIndex * viewsPerPage
            let endIndex = min(startIndex + viewsPerPage, eventsArray.count)
            
            for row in 0..<rowsPerPage {
                let yTranslation = CGFloat(row) * (viewHeight + spacing) + spacing
                
                for col in 0..<viewsPerRow {
                    let index = startIndex + row * viewsPerRow + col
                    
                    if index < endIndex, let event = eventsArray[safe: index] {
                        let xTranslation = CGFloat(col) * (viewWidth + spacing)
                        print("Position for event(\(index)) is  x= \(xTranslation) / y = \(yTranslation)")
                        
                        let renderer = ImageRenderer(content: GridView(recipient: recipient, event: event, printView: true).frame(width: viewWidth, height: viewHeight).scaledToFit())
                        renderer.render { size, context in
                            pdf.translateBy(
                                x: xTranslation,
                                y: yTranslation
                            )
                            context(pdf)
                        }
                    }
                }
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
