//
//  VIewEventsView.swift
//  HolidayCardTracker
//
//  Created by Michael Rowe on 12/30/20.
//

import SwiftUI
import CoreData

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
                        Text("\(recipient.addressLine1 ?? "")")
                            .foregroundColor(.green)
                            .padding([.top], 10)
                        if recipient.addressLine2 != "" {
                            Text("\(recipient.addressLine2 ?? "")")
                                .foregroundColor(.green)
                        }
                        Text("\(recipient.city ?? ""), \(recipient.state ?? "") \(recipient.zip ?? "")")
                            .foregroundColor(.green)
                        Text("\(recipient.country ?? "")")
                            .foregroundColor(.green)
                    }
                    .padding([.leading, .trailing], 10 )
                    Spacer()
                }

                List {
                    ForEach(events, id: \.self) { event in
                        NavigationLink(destination: ViewAnEventView(event: event, recipient: recipient)) {
                            HStack {
                                VStack {
                                    Spacer()
                                    Text("\(event.event ?? "Unknown Event")")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                    Text("\(event.eventDate!, formatter: Self.eventDateFormatter)")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                    Spacer()
                                }
                                Spacer()
                                if event.cardFrontImage != nil {
                                    Image(uiImage: (event.cardFrontImage ?? UIImage(contentsOfFile: "frontImage"))!)
                                        .resizable()
//                                        .frame(width: 120, height: 120)
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    Image("frontImage")
                                        .resizable()
//                                        .frame(width: 120, height: 120)
                                        .aspectRatio(contentMode: .fit)
                                }
//                                if event.cardBackImage != nil {
//                                    Image(uiImage: (event.cardBackImage ?? UIImage(contentsOfFile: "backImage"))!)
//                                        .resizable()
//                                        .frame(width: 75, height: 120)
//                                        .aspectRatio(contentMode: .fit)
//                                } else {
//                                    Image("backImage")
//                                        .resizable()
//                                        .frame(width: 75, height: 120)
//                                        .aspectRatio(contentMode: .fit)
//                                }
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

    private func addEvent() {
        // replace with Actual AddEvent Logic
        let newEntry = Event(context: self.moc)
        newEntry.event = "Christmas"
        newEntry.eventDate = Date() as NSDate
        newEntry.cardFrontImage = UIImage(contentsOfFile: "frontImage")
        newEntry.cardBackImage = UIImage(contentsOfFile: "frontImage")
        newEntry.recipient = recipient
        if self.moc.hasChanges {
            try? self.moc.save()
        }
    }
}

struct ViewEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ViewEventsView(recipient: Recipient())
    }
}
