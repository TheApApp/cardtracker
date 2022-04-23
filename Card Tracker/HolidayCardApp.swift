//
//  HolidayCardApp.swift
//  Card Tracker
//
//  Created by Michael Rowe on 12/28/20.
//  Copyright © 2020 Michael Rowe. All rights reserved.
//

import os
import SwiftUI

@main
struct HolidayCardApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let context = PersistentCloudKitContainer.persistentContainer.viewContext

    var body: some Scene {
        WindowGroup {
            ViewRecipientsView().accentColor(.green)
                .environment(\.managedObjectContext, context)
        }
        .commands {
            CommandGroup(replacing: .help) {
                EmptyView()
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("\(#function) REPORTS - App change of scenePhase to ACTIVE")
                //                saveContext()
            case .inactive:
                print("\(#function) REPORTS - App change of scenePhase to INACTIVE")
                saveContext()
            case .background:
                print("\(#function) REPORTS - App change of scenePhase to BACKGROUND")
                saveContext()
            @unknown default:
                fatalError("\(#function) REPORTS - fatal error in switch statement for .onChange modifier")
            }
        }
    }

    func saveContext() {
        let logger=Logger(subsystem: "com.theapapp.christmascardtracker", category: "HolidayCardApp")
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                logger.log("unresolved errorL \(nserror), \(nserror.userInfo)")
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
