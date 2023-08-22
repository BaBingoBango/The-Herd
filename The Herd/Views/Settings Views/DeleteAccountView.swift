//
//  DeleteAccountView.swift
//  The Herd
//
//  Created by Ethan Marshall on 8/20/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

/// An app view written in SwiftUI!
struct DeleteAccountView: View {
    
    // MARK: View Variables
    @ObservedObject var currentUser: User
    @State var deleteAccount = Operation()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var secondsLeft = 0
    @State var reauth = Operation()
    @State var showingPhoneCodeView = false
    @AppStorage("phoneSignInVerificationID") var phoneSignInVerificationID: String = ""
    @State var phoneAuthCredential: PhoneAuthCredential? = nil
    
    // MARK: View Body
    var body: some View {
        VStack {
            Image(systemName: "person.fill.xmark")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .padding(.top)
            
            Text("Confirm Account Deletion")
                .dynamicFont(.title, lineLimit: 5)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .padding(.top, 5)
            
            Spacer()
            
            InformationalRowView(iconName: "person.crop.circle.dashed", text: "All of your user data will be deleted, including your preferences, emoji, color, and post history.")
                .padding(.bottom)
            
            InformationalRowView(iconName: "ellipsis.bubble.fill", text: "Your posts and comments won't be removed, but you won't be able to access them anymore.")
                .padding(.bottom)
            
            InformationalRowView(iconName: "key.fill", text: "Your login information will be removed, so you'll have to create a new account to use the app again.")
                .padding(.bottom)
            
            if secondsLeft == 0 {
                InformationalRowView(iconName: "lock.fill", text: "You'll have to sign in to confirm the deletion. After that, you'll have five minutes to proceed.", color: .gray)
            } else {
                InformationalRowView(iconName: "checkmark.circle.fill", text: "You have \(String(format: "%02d", secondsLeft / 60)):\(String(format: "%02d", secondsLeft % 60)) left to confirm your deletion before you'll need to sign in again.", color: .green)
            }
            
            Spacer()
            
            ZStack {
                Button(action: {
                    if secondsLeft != 0 {
                        deleteUserAccount()
                    } else {
                        reauthenticate()
                    }
                }) {
                    Text(deleteAccount.status == .inProgress || reauth.status == .inProgress ? "" : (secondsLeft == 0 ? "Sign In" : "Confirm Deletion"))
                        .dynamicFont(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(deleteAccount.status != .inProgress ? .white : .clear)
                        .modifier(RectangleWrapper(fixedHeight: 55,
                                                   color: deleteAccount.status == .inProgress || reauth.status == .inProgress ? .gray : .red,
                                                   opacity: deleteAccount.status == .inProgress || reauth.status == .inProgress ? 0.2 : 1))
                        .padding(.bottom)
                }
                .disabled(deleteAccount.status == .inProgress || reauth.status == .inProgress)
                .alert(isPresented: $deleteAccount.isShowingErrorMessage) {
                    Alert(title: Text("Couldn't Delete Account"),
                          message: Text(deleteAccount.errorMessage),
                          dismissButton: .default(Text("Close")))
                }
                .sheet(isPresented: $showingPhoneCodeView) {
                    PhoneSignInView(phoneSignInVerificationID: phoneSignInVerificationID, phoneAuthCredential: $phoneAuthCredential, hideStartOverButton: true)
                }
                
                if deleteAccount.status == .inProgress || reauth.status == .inProgress {
                    ProgressView()
                        .padding(.bottom)
                }
            }
            .alert(isPresented: $reauth.isShowingErrorMessage) {
                Alert(title: Text("Couldn't Sign In"),
                      message: Text(reauth.errorMessage),
                      dismissButton: .default(Text("Close")))
            }
        }
        .padding(.horizontal)
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(deleteAccount.status == .inProgress || reauth.status == .inProgress)
        .interactiveDismissDisabled(deleteAccount.status == .inProgress || reauth.status == .inProgress) // TODO: NEXT: test phone auth delete account
        .onReceive(timer) { _ in
            secondsLeft = max(secondsLeft - 1, 0)
        }
        .onChange(of: phoneAuthCredential) { _ in
            if let phoneAuthCredential = phoneAuthCredential {
                Auth.auth().currentUser!.reauthenticate(with: phoneAuthCredential) { result, error in
                    
                    // Check for errors!
                    if let error = error {
                        reauth.setError(message: error.localizedDescription)
                    } else {
                        reauth.status = .success
                        secondsLeft = 60 * 5
                    }
                }
            } else {
                reauth.setError(message: "No phone authentication credential was found.")
            }
        }
        .onChange(of: showingPhoneCodeView) { _ in
            if !showingPhoneCodeView && reauth.status == .inProgress {
                reauth.status = .notStarted
                phoneSignInVerificationID = ""
            }
        }
    }
    
    // MARK: View Functions
    func reauthenticate() {
        reauth.status = .inProgress
        
        if let providerID = Auth.auth().currentUser?.providerData.first?.providerID {
            switch providerID {
            case GoogleAuthProviderID:
                // Get the Firebase client ID!
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    reauth.setError(message: "There was a problem retrieving the Firestore client ID.")
                    return
                }
                
                // Start Google Sign-In!
                GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.signIn(withPresenting: (UIApplication.shared.connectedScenes.first as! UIWindowScene).windows.first!.rootViewController!) { result, error in
                    
                    // Check for errors!
                    if let error = error {
                        reauth.setError(message: error.localizedDescription)
                    }
                    
                    // Get the user and the ID token!
                    guard let user = result?.user, let IDtoken = user.idToken?.tokenString else {
                        reauth.setError(message: "There was a problem retrieving the user ID token.")
                        return
                    }
                    
                    // Get the credential and complete sign in!
                    let credential = GoogleAuthProvider.credential(withIDToken: IDtoken, accessToken: user.accessToken.tokenString)
                    Auth.auth().currentUser!.reauthenticate(with: credential) { result, error in
                        
                        // Check for errors!
                        if let error = error {
                            reauth.setError(message: error.localizedDescription)
                        } else {
                            reauth.status = .success
                            secondsLeft = 60 * 5
                        }
                    }
                }
                
            case PhoneAuthProviderID:
                // Send the verification code!
                PhoneAuthProvider.provider().verifyPhoneNumber(Auth.auth().currentUser!.providerData.first!.phoneNumber!, uiDelegate: nil) { verificationID, error in
                    
                    if let error = error {
                        reauth.setError(message: error.localizedDescription)
                        
                    } else {
                        if let verificationID = verificationID {
                            phoneSignInVerificationID = verificationID
                            showingPhoneCodeView = true
                        } else {
                            reauth.setError(message: "Couldn't access the phone verification ID.")
                        }
                    }
                }
                
            default:
                reauth.setError(message: "The sign-in provider \"\(providerID)\" was not recognized.")
            }
        } else {
            reauth.setError(message: "Couldn't access the provider ID for the current user.")
        }
    }
    func deleteUserAccount() {
        deleteAccount.status = .inProgress
        
        // Start by deleting the User object for this user!
        usersCollection.document(currentUser.UUID).delete() { error in
            if let error = error { deleteAccount.setError(message: error.localizedDescription); return }
            
            // Then, delete the Auth record!
            Auth.auth().currentUser!.delete() { error in
                if let error = error { deleteAccount.setError(message: error.localizedDescription); return }
                
                // Finally, sign out!
                do {
                    try Auth.auth().signOut()
                } catch {
                    deleteAccount.setError(message: error.localizedDescription); return
                }
                
                deleteAccount.status = .success
            }
        }
    }
}

// MARK: View Preview
struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeleteAccountView(currentUser: .getSample())
        }
    }
}

// MARK: Support Views
struct InformationalRowView: View {
    
    var iconName: String
    var text: String
    var headingText: String?
    var color = Color.red
    var showSpinner = false
    
    var body: some View {
        HStack {
            ZStack {
                Image(systemName: iconName)
                    .font(.system(size: 25))
                    .foregroundColor(color)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 50)
                    .opacity(showSpinner ? 0.15 : 1)
                
                if showSpinner {
                    ProgressView()
                        .frame(width: 50)
                }
            }
            
            VStack(alignment: .leading) {
                if let headingText = headingText {
                    Text(headingText)
                        .dynamicFont(.body, lineLimit: 15, minimumScaleFactor: 0.1, padding: 0)
                        .fontWeight(.bold)
                }
                
                Text(text)
                    .dynamicFont(.body, lineLimit: 15, minimumScaleFactor: 0.1, padding: 0)
            }
            
            Spacer()
        }
    }
}
