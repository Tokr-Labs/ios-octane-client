//
//  SolanaPayTransactionInstructionStatus.swift
//  OctaneClient
//
//  Created by Eric McGary on 10/12/22.
//

import Foundation

enum SolanaPayTransactionInstructionStatus {
    case initial
    case creating
    case success
    case failure(_ error: Error)
}
