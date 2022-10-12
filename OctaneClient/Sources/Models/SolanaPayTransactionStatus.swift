//
//  SolanaPayTransactionStatus.swift
//  OctaneClient
//
//  Created by Eric McGary on 10/12/22.
//

import Foundation

enum SolanaPayTransactionStatus {
    
    case initial
    case idle
    case inProgress
    case success
    case failure(_ error: Error)
    
}
