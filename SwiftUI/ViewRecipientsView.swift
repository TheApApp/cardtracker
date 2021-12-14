import SwiftUI
import CoreData

struct ViewRecipientsView: View {
    @Environment(\.managedObjectContext) var moc
    @State var predicate: NSPredicate?
    @State var addNewRecipient = false
    @FetchRequest private var recipients: FetchedResults<Recipient>
    @State var newEvent = false

    init() {
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

        let request: NSFetchRequest<Recipient> = Recipient.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Recipient.lastName, ascending: true),
            NSSortDescriptor(keyPath: \Recipient.firstName, ascending: true)
        ]
        _recipients = FetchRequest<Recipient>(fetchRequest: request)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(recipients, id: \.self) { recipient in
                    NavigationLink(destination:
                                    ViewEventsView(recipient: recipient)) {
                        Text("\(recipient.firstName ?? "no first name") \(recipient.lastName ?? "no last name")")
                            .foregroundColor(.green)
                    }
                }
                .onDelete(perform: deleteRecipient)
            }
            .navigationTitle("Recipient List")
            .navigationBarItems(trailing:
                                    HStack {
                                        Button(action: {
                                            self.addNewRecipient.toggle()
                                        }, label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(.green)
                                        })
                                    }
            )
            Text("Select a Recipient")
                .font(.largeTitle)
                .foregroundColor(.green)
        }
        .ignoresSafeArea(.all)
        .sheet(isPresented: $addNewRecipient) {
            AddNewRecipientView()
        }
    }

    private func deleteRecipient(offsets: IndexSet) {
        withAnimation {
            offsets.map { recipients[$0] }.forEach(moc.delete)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ViewRecipientsView()
            .environment(\.managedObjectContext, PersistentCloudKitContainer.persistentContainer.viewContext)
    }
}
