//
//  SolanaPaySheet.swift
//  SaucyCode
//
//  Created by Eric McGary on 10/11/22.
//

import SwiftUI
import Solana

struct SolanaPaySheet: View {
    
    var status: SolanaPayTransactionStatus = .initial
    var specification: SolanaPaySpecification?
    var approve: () -> Void
    var dismiss: (() -> Void)?
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            switch status {
                case .initial:
                    ProgressView()
                        .progressViewStyle(.circular)
                case .idle, .inProgress:
                    info
                case .success:
                    Text("\(Image(systemName: "checkmark")) Success")
                case .failure(let error):
                    Text("Failure: \(error.localizedDescription)")
            }
            
        }
        
    }
    
    // ============================================================
    // === Private API ============================================
    // ============================================================
    
    // MARK: - Private API
    
    // MARK: Private Properties
    
    private var isButtonDisabled: Bool {
        
        switch status {
            case .initial:
                return true
                
            default:
                return false
        }
        
    }
    
    private var info: some View {
        
        VStack {
            
            Text(specification?.label ?? "")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 24)
                            
            Spacer()
            
            VStack(spacing: 24) {
                
                Divider()
                
                HStack {
                    
                    Text("Total")
                        .font(.system(size: 18, weight: .regular))
                    
                    Spacer()
                    
                    HStack {
                        Text("\(specification?.amount ?? 0)")
                        Text("\((specification?.splToken?.base58EncodedString ?? "--"))")
                            .frame(width: 100)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .font(.system(size: 18, weight: .medium))
                    
                }
                
            }
            .padding(.bottom, 24)

            
            Button {
                
                approve()
                
            } label: {
                
                buttonContent
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                    .background(Color.blue.cornerRadius(10))
                    .tint(.white)
                
            }
            .disabled(isButtonDisabled)
            
        }
        
    }
    
    @ViewBuilder private var buttonContent: some View {
        
        switch status {
            case .inProgress:
                ProgressView()
                    .progressViewStyle(.circular)
                
            default:
                Text("Approve")
                    .font(.system(.headline))
                
        }
        
    }
    
}

struct SolanaPaySheet_Previews: PreviewProvider {
    static var previews: some View {
        SolanaPaySheet {
            // ...
        }
        .padding(24)
    }
}
