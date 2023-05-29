//
//  The_HerdApp.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import SwiftUI

@main
struct The_HerdApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
