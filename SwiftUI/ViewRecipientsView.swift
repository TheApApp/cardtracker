import SwiftUI
import CoreData

struct ViewRecipientsView: View {
    @Environment(\.managedObjectContext) var moc
    @State var predicate: NSPredicate?
    @State var addNewRecipient = false
    @FetchRequest private var recipients: FetchedResults<Recipient>
    @State var newEvent = false

    @State private var lastNameFilter = ""
    @State private var firstNameFilter = ""

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
            VStack {
                HStack {
                    TextField("Filter", text: $lastNameFilter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.all)
                FilteredList(filter: lastNameFilter)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ViewRecipientsView()
            .environment(\.managedObjectContext, PersistentCloudKitContainer.persistentContainer.viewContext)
    }
}
