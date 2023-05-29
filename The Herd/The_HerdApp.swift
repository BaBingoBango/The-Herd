//
//  The_HerdApp.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import SwiftUI
import FirebaseCore

@main
struct The_HerdApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Text("hello, old yak!")
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: App Launch Code
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Start up Firebase!
        FirebaseApp.configure()

        // We did it!
        return true
    }
}
