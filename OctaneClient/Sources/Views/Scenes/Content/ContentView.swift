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
    
    @AppStorage("simulatedScannerData") var simulatedScannerData = ""
    
    @StateObject var viewModel = ContentViewModel()
    
    // MARK: Internal Properties
        
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 24) {
                
                Text("Last Transaction Signature:")
                    .font(.system(.headline))
                
                if viewModel.transactionSignature != nil {
                    
                    Text(viewModel.transactionSignature!)
                        .textSelection(.enabled)
                    
                } else {
                    
                    Text("--")
                    
                }
                
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(
                    placement: .navigationBarTrailing
                ) {

                    Button {
                        isPresentingScanner = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }

                }
                
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
        
        .sheet(
            isPresented: $isPresentingScanner,
            onDismiss: {
                isPresentingScanner = false
            }
        ) {
            
            NavigationStack {
                
                CodeScannerView(codeTypes: [.qr], simulatedData: simulatedScannerData) { response in
                
                    isPresentingScanner = false
                    
                    if case let .success(result) = response {
                        viewModel.handleSolanaPayUrl(result.string)
                    }
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    
                    ToolbarItem(
                        placement: .navigationBarTrailing
                    ) {
                        
                        Button {
                            isPresentingScanner = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .sheet(isPresented: $isPresentingSolanaPaySpecificationData) {
            
            SolanaPaySheet(
                status: viewModel.transactionStatus ?? .initial,
                specification: viewModel.solanaPaySpecification,
                approve: {
                    viewModel.approveTransaction()
                },
                dismiss: {
                    isPresentingSolanaPaySpecificationData = false
                }
            )
            .padding(24)
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
            
        }
        .onReceive(viewModel.$solanaPaySpecification) { output in
            if output != nil {
                isPresentingSolanaPaySpecificationData = true
            }
        }
        
        
    }
    
    // ============================================================
    // === Private API ============================================
    // ============================================================
    
    // MARK: - Private API
    
    // MARK: Private Properties
    
    @State private var scannedCode = ""
    @State private var isPresentingScanner = false
    @State private var isPresentingSolanaPaySpecificationData = false
    
    // MARK: Private Methods
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
