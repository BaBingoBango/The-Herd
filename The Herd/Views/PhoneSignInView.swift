//
//  PhoneSignInView.swift
//  The Herd
//
//  Created by Ethan Marshall on 6/11/23.
//

import SwiftUI
import iPhoneNumberField
import FirebaseAuth

/// An app view written in SwiftUI!
struct PhoneSignInView: View {
    
    // MARK: View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @State var enteredPhoneNumber = "+1"
    @State var sendCode = Operation()
    @AppStorage("phoneSignInVerificationID") var phoneSignInVerificationID: String = ""
    @State var enteredVerificationCode = ""
    @State var verify = Operation()
    
    // MARK: View Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("📞")
                        .font(.system(size: 70))
                        .padding(.bottom, 5)
                    
                    Text(phoneSignInVerificationID.isEmpty ? "Continue with Phone Number" : "Enter Verification Code")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    if phoneSignInVerificationID.isEmpty {
                        iPhoneNumberField("+1 (123) 456-7890", text: $enteredPhoneNumber)
                            .multilineTextAlignment(.center)
                            .font(UIFont(size: 27.5, weight: .bold, design: .rounded))
                            .prefixHidden(false)
                            .flagHidden(false)
                            .flagSelectable(false)
                            .maximumDigits(10)
                            .padding()
                            .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 10)
                            .padding(.vertical)
                        
                    } else {
                        TextField("123456", text: $enteredVerificationCode)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 30, design: .monospaced))
                            .padding()
                            .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 10)
                            .padding(.vertical)
                    }
                    
                    HStack {
                        Text(phoneSignInVerificationID.isEmpty ?
                             "Standard carrier rates apply for SMS verification messages.\n\nYour phone number will be sent and stored by Google to improve their spam and abuse prevention. For more information, return to the previous screen and tap Sign-in Security and Privacy." :
                             "Enter the 6-digit code you received at the phone number you entered on the previous screen.\n\nIf you didn't get a code or misentered your number, tap Start Over.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                }
                .padding([.horizontal, .bottom])
                
                // MARK: Navigation Settings
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .fontWeight(.bold)
                        }
                    }
                })
            }
            
            Button(action: {
                if phoneSignInVerificationID.isEmpty {
                    sendCode.status = .inProgress
                    
                    PhoneAuthProvider.provider().verifyPhoneNumber(enteredPhoneNumber, uiDelegate: nil) { verificationID, error in
                        
                        if let error = error {
                            sendCode.setError(message: error.localizedDescription)
                            
                        } else {
                            phoneSignInVerificationID = verificationID!
                            sendCode.status = .success
                        }
                    }
                    
                } else {
                    verify.status = .inProgress
                    
                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: phoneSignInVerificationID, verificationCode: enteredVerificationCode)
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        
                        if let error = error {
                            verify.setError(message: error.localizedDescription)
                            sendCode.setError(message: error.localizedDescription)
                            
                        } else {
                            phoneSignInVerificationID = ""
                            verify.status = .success
                        }
                    }
                }
            }) {
                if sendCode.status != .inProgress && verify.status != .inProgress {
                    Text("Submit!")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .accentColor))
                } else {
                    ProgressView()
                        .modifier(RectangleWrapper(fixedHeight: 55, color: .gray.opacity(0.25)))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, phoneSignInVerificationID.isEmpty ? 15 : 0)
            
            if !phoneSignInVerificationID.isEmpty {
                Button(action: {
                    phoneSignInVerificationID = ""
                }) {
                    Text("Start Over")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .padding(.bottom)
                        .padding(.top, 1)
                }
            }
        }
        .alert(isPresented: $sendCode.isShowingErrorMessage) {
            Alert(title: Text("Couldn't Sign In"),
                  message: Text(sendCode.errorMessage),
                  dismissButton: .default(Text("Close")))
        }
    }
    
    // MARK: View Functions
    // Functions go here! :)
}

// MARK: View Preview
struct PhoneSignInView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneSignInView()
    }
}

// MARK: Support Views
// Support views go here! :)
