//
//  SignInView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/11/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

/// An app view written in SwiftUI!
struct SignInView: View {
    
    // MARK: View Variables
    @State var showingPhoneSignInView = false
    @State var googleSignIn = Operation()
    @State var showingSignInInfoView = false
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color.accentColor.gradient)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.15)
                
                VStack {
                    Text("app logo!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 45, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    
                    Text("Sign Up or Log In")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .offset(y: 15)
                        .padding(.bottom, 60)
                    
                    Button(action: {
                        showingPhoneSignInView = true
                    }) {
                        AuthenticationOptionView(emoji: "📞", text: "Continue with Phone")
                    }
                    .sheet(isPresented: $showingPhoneSignInView) {
                        PhoneSignInView(phoneAuthCredential: .constant(nil))
                    }
                    
                    Button(action: {
                        googleSignIn.status = .inProgress
                        
                        // Get the Firebase client ID!
                        guard let clientID = FirebaseApp.app()?.options.clientID else {
                            googleSignIn.setError(message: "There was a problem retrieving the Firestore client ID.")
                            return
                        }
                        
                        // Start Google Sign-In!
                        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
                        GIDSignIn.sharedInstance.signIn(withPresenting: (UIApplication.shared.connectedScenes.first as! UIWindowScene).windows.first!.rootViewController!) { result, error in
                            
                            // Check for errors!
                            if let error = error {
                                googleSignIn.setError(message: error.localizedDescription)
                            }
                            
                            // Get the user and the ID token!
                            guard let user = result?.user, let IDtoken = user.idToken?.tokenString else {
                                googleSignIn.setError(message: "There was a problem retrieving the user ID token.")
                                return
                            }
                            
                            // Get the credential and complete sign in!
                            let credential = GoogleAuthProvider.credential(withIDToken: IDtoken, accessToken: user.accessToken.tokenString)
                            Auth.auth().signIn(with: credential) { result, error in
                                
                                // Check for errors!
                                if let error = error {
                                    googleSignIn.setError(message: error.localizedDescription)
                                }
                            }
                        }
                    }) {
                        AuthenticationOptionView(imageName: "google icon", text: "Continue with Google", isInProgress: googleSignIn.status == .inProgress)
                    }
                    .alert(isPresented: $googleSignIn.isShowingErrorMessage) {
                        Alert(title: Text("Couldn't Sign In"),
                              message: Text(googleSignIn.errorMessage),
                              dismissButton: .default(Text("Close")))
                    }
                    
                    AuthenticationOptionView(systemIconName: "applelogo", text: "Continue with Apple")
                    
                    Button(action: {
                        showingSignInInfoView = true
                    }) {
                        HStack {
                            Text("Sign-in Security and Privacy")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.top, 5)
                    }
                    .sheet(isPresented: $showingSignInInfoView) {
                        // TODO
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: View Functions
    struct AuthenticationOptionView: View {
        
        var emoji: String?
        var imageName: String?
        var systemIconName: String?
        var text: String
        var isInProgress = false
        
        var body: some View {
            HStack {
                if isInProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 1)
                    
                } else {
                    if emoji != nil {
                        Text(emoji!)
                            .font(.system(size: 27))
                    }
                    
                    if imageName != nil {
                        Image(imageName!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                        
                    }
                    
                    if systemIconName != nil {
                        Image(systemName: systemIconName!)
                            .font(.system(size: 27))
                            .foregroundColor(.black)
                    }
                }
                
                Text(text)
                    .font(.system(size: 22.5))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.leading, 5)
            }
            .modifier(RectangleWrapper(fixedHeight: 60, color: isInProgress ? .gray : .accentColor))
        }
    }
}

// MARK: View Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

// MARK: Support Views
// Support views go here! :)
