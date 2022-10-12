//
//  TransferError.swift
//  OctaneClient
//
//  Created by Eric McGary on 10/12/22.
//

import Foundation

enum TransferError: Error {
    
    case missingData
    case invalidMint
    case invalidSenderAccount
    case invalidRecipientAccount
    case insufficientFunds
    
}

extension TransferError: LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
            case .missingData:
                return NSLocalizedString("Missing data.", comment: "")
    
            case .invalidMint:
                return NSLocalizedString("Invalid mint.", comment: "")
            
            case .invalidSenderAccount:
                return NSLocalizedString("Invalid sender account.", comment: "")
            
            case .invalidRecipientAccount:
                return NSLocalizedString("Invalid recipient account.", comment: "")
            
            case .insufficientFunds:
                return NSLocalizedString("Insufficient funds", comment: "")
                
        }
        
    }
    
}
