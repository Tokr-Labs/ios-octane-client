//
//  ContentViewModel.swift
//  OctaneClient
//
//  Created by Eric McGary on 10/12/22.
//

import Foundation
import Solana
import SwiftUI

class ContentViewModel: ObservableObject {
    
    // ============================================================
    // === Internal API ===========================================
    // ============================================================
    
    // MARK: - Internal API
    
    // MARK: Internal Properties
    
    @AppStorage("secretkey") var secretKey = ""
    @AppStorage("feePayer") var feePayer = ""

    @Published var transactionSignature: String?
    @Published var isSendingTransaction = false
    
    // MARK: Internal Methods
    
    init() {
        
        let network = NetworkingRouter(
            endpoint: RPCEndpoint(
                url: URL(string: "https://api.devnet.solana.com")!,
                urlWebSocket: URL(string: "wss://api.devnet.solana.com")!,
                network: .devnet
            )
        )
        
        solana = Solana(
            router: network,
            tokenProvider: EmptyInfoTokenProvider()
        )
        
    }
    
    func send() {
        
        isSendingTransaction = true
        
        Task {
            
            do {
                
                let signature = try await self.sendTransaction()
                                
                DispatchQueue.main.async {
                    self.transactionSignature = signature
                    self.isSendingTransaction = false
                }
                
            } catch {
                
                print(error)
                
                DispatchQueue.main.async {
                    self.isSendingTransaction = false
                }
                
            }
            
        }
        
    }
    
    // ============================================================
    // === Private API ============================================
    // ============================================================
    
    // MARK: - Private API
    
    // MARK: Private Properties
    
    private let solana: Solana
    private let octaneService = OctaneService()
    private var instruction: TransactionInstruction?
    
    private var account: HotAccount {
        let sk = Base58.decode(secretKey)
        return HotAccount(secretKey: Data(bytes: sk, count: sk.count))!
    }
    
    // MARK: Private Methods
        
    private func sendTransaction() async throws -> String? {
        
        let recentBlockhash = try await solana.api.getRecentBlockhash()
        
        var transaction = Transaction(
            feePayer: PublicKey(string: feePayer)!,
            instructions: [createMemoInstruction()],
            recentBlockhash: recentBlockhash
        )
        
        try transaction.sign(signers: [account]).get()
        
        let serializedTransaction = try transaction.serialize(requiredAllSignatures: false).get()
        
        let response = try await octaneService.send(
            serializedTransaction: serializedTransaction.bytes.toBase64()
        )
        
        return response
        
    }
    
    private func createMemoInstruction() -> TransactionInstruction {
        
        let keys = [
            AccountMeta(publicKey: account.publicKey, isSigner: true, isWritable: false)
        ]

        let data = "Simple Memo".data(using: .utf8)
        
        return TransactionInstruction(
            keys: keys,
            programId: PublicKey(string: "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr")!,
            data: data?.bytes ?? []
        )
    }
    
}
