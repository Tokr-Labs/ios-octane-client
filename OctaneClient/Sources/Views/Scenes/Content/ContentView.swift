//
//  ContentView.swift
//  OctaneClient
//
//  Created by Eric McGary on 10/12/22.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    
    // ============================================================
    // === Internal API ===========================================
    // ============================================================
    
    // MARK: - Internal API
    
    @StateObject var viewModel = ContentViewModel()
    
    // MARK: Internal Properties
        
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 24) {
                
                Text("Last Transaction Signature:")
                    .font(.system(.headline))
                
                Text(try! AttributedString(markdown:
                    viewModel.transactionSignature != nil ? "https://explorer.solana.com/tx/\(viewModel.transactionSignature!)?cluster=devnet" : "--"))

                if !viewModel.isSendingTransaction {
                    Button {
                        viewModel.send()
                    } label: {
                        Text("Send Transaction")
                    }
                } else {
                    ProgressView().progressViewStyle(.circular)
                }
                
                
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {
                    
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                }
                
            }
            
        }
        
    }
   
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
