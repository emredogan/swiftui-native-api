//
//  ContentView.swift
//  SwiftUI_NativeAPI
//
//  Created by Emre Dogan on 01/08/2022.
//

import SwiftUI
import LocalAuthentication
import CoreNFC

struct ContentView: View {
    @State private var isUnlocked = false
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        VStack {
            if isUnlocked {
                NFCView()
                
            } else {
                VStack(alignment: .center, spacing: 25) {
                    LottieView(name: "movie")

                    TextField("Email", text: $email)
                        .cornerRadius(8)
                        .padding()
                    TextField("Pasword", text: $password)
                        .cornerRadius(8)
                        .padding()
                    Button("Login") {
                        authenticate()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(8)
                    .padding()
                    
                }
                
            }
        }
        .onAppear {
            authenticate()
        }
        
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                if(success) {
                    
                    isUnlocked = true
                } else {
                    isUnlocked = false
                }
            }
        } else {
            // No biometrics
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct NFCView: View{
    @State var urlT = ""
    @State var writer = NFCReader()
    var body: some View {
        VStack {
            Text("No data")
                .padding(100)
                .border(.black)
            Spacer()
            Spacer()
            Button {
                print("Button tapped")
                writer.scan(theActualData: urlT)
                
            } label: {
                Text("Scan NFC")
            }.foregroundColor(.white)
                .padding()
                .background(.blue)
                .cornerRadius(8)
                .padding()

        }
    }
    
}

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    var theActualData = ""
    var nfcSession: NFCNDEFReaderSession?
    
    func scan(theActualData: String) {
        self.theActualData = theActualData
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near an NFC Card"
        nfcSession?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        let str: String = theActualData
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than one Tag Detected, please try again"
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
                session.restartPolling()
            }
            return
            
        }
        
        let tag = tags.first!
        session.connect(to: tag) { error in
            if nil != error {
                session.alertMessage = "Unable to connect to Tag"
                session.invalidate()
                return
            }
            tag.queryNDEFStatus { ndefstatus, capacity, error in
                guard error  == nil else {
                    session.alertMessage = "Unable to connect to Tag"
                    session.invalidate()
                    return
                }
                
                switch ndefstatus {
                case .notSupported:
                    session.alertMessage = "Unable to connect to Tag"
                    session.invalidate()
                case .readWrite:
                    session.alertMessage = "Unable to write to Tag"
                    session.invalidate()
                case .readOnly:
                    tag.writeNDEF(.init(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: "\(str)")!])) { error in
                        if nil != error {
                            session.alertMessage = "Write NFC Message fail"
                        } else {
                            session.alertMessage = "You have successfully your tag!"
                        }
                        
                        session.invalidate()
                    }
                @unknown default:
                    session.alertMessage = "Unknown error"
                    session.invalidate()
                }
            }
        }
    }
    
    
}
