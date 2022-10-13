//
//  SettingsView.swift
//  OctaneClient
//
//  Created by Eric McGary on 10/12/22.
//

import SwiftUI

struct SettingsView: View {
    
    // ============================================================
    // === Internal API ===========================================
    // ============================================================
    
    // MARK: - Internal API
    
    // MARK: Internal Properties
    
    @AppStorage("secretkey") var secretKey = ""
    @AppStorage("feePayer") var feePayer = ""
    @AppStorage("octaneServer") var octaneServer = ""

    var body: some View {
        
        Form {
           
            Section {
                TextField(text: $octaneServer, axis: .vertical) {
                    Text("https://example.com")
                }
                .lineLimit(3...5)
            } header: {
                Text("Octane Server")
            } footer: {
                Text("The location of the octane server transactions will be sent to.")
            }
            
            Section {
                TextField(text: $secretKey, axis: .vertical) {
                    Text("Secret Key")
                }
                .lineLimit(3...5)
            } header: {
                Text("Hot Wallet")
            } footer: {
                Text("This is the user's wallet. For example if you have access to the user's private key via Web3Auth.")
            }
            
            Section {
                TextField(text: $feePayer, axis: .vertical) {
                    Text("Public Key")
                }
                .lineLimit(3...5)
            } header: {
                Text("Octane Fee Payer")
            } footer: {
                Text("This is the Public Key of the wallet being used to pay for the hot wallets transaction fees.")
            }
           
        }
        
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
