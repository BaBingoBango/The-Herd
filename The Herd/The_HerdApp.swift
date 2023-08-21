//
//  The_HerdApp.swift
//  The Herd
//
//  Created by Ethan Marshall on 5/29/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

// MARK: Firestore Paths
/// The Firestore path to the `users` collection.
var usersCollection = Firestore.firestore().collection("users")
/// The Firestore path to the `posts` collection.
var postsCollection = Firestore.firestore().collection("posts")
/// The Firestore path to the `chats` collection.
var chatsCollection = Firestore.firestore().collection("chats")
/// The Firestore path to the `system` collection.
var systemCollection = Firestore.firestore().collection("system")

@main
struct The_HerdApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DispatchView()
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
        
        // TODO: Clear the offline cache?
        Firestore.firestore().clearPersistence()

        // We did it!
        return true
    }
    
    // MARK: URL Handler
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Send URLs to Google Sign-In!
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: Remote Notification Handler
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Send notifications to Firebase Auth!
        Auth.auth().canHandleNotification(userInfo)
    }
}
