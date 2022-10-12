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

    @Published var solanaPaySpecification: SolanaPaySpecification?
    @Published var solanaPayTransactionInstructionStatus: SolanaPayTransactionInstructionStatus? = .initial
    @Published var transactionStatus: SolanaPayTransactionStatus? = .initial
    @Published var transactionSignature: String?
    
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
    
    func handleSolanaPayUrl(_ value: String) {
        
        do {
            
            let parser = solana.pay.parseSolanaPay(urlString: value)
            let spec = try parser.get()
            
            DispatchQueue.main.async {
                
                delay(interval: 0.35) {
                    self.solanaPaySpecification = spec
                }
                
                self.solanaPayTransactionInstructionStatus = .creating
                self.transactionStatus = .idle
                
            }
            
            Task {
                
                do {
                    
                    let instruction = try await createTransferInstruction(
                        connection: solana,
                        sender: account.publicKey,
                        data: spec
                    )
                    
                    DispatchQueue.main.async {
                        self.solanaPayTransactionInstructionStatus = .success
                        self.instruction = instruction
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        self.solanaPayTransactionInstructionStatus = .failure(error)
                    }
                    
                }
                
            }
            
        } catch {
            
            self.solanaPayTransactionInstructionStatus = .failure(error)

        }
        
    }
    
    func approveTransaction() {
        
        transactionStatus = .inProgress
        
        Task {
            
            do {
                
                let signature = try await self.sendTransaction()
                
                print(String(describing: signature))
                
                DispatchQueue.main.async {
                    self.transactionSignature = signature
                    self.transactionStatus = .success
                }
                
                
            } catch {
                
                DispatchQueue.main.async {
                    self.transactionStatus = .failure(error)
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
        
        // get most recent blockhash
        let recentBlockhash = try await solana.api.getRecentBlockhash()
        
        // create the transaction
        
        var transaction = Transaction(
            feePayer: PublicKey(string: feePayer)!,
            instructions: [self.instruction!],
            recentBlockhash: recentBlockhash
        )
        
        try transaction.sign(signers: [account]).get()
        
        let serializedTransaction = try transaction.serialize(requiredAllSignatures: false).get()
        
        let response = try await octaneService.send(
            serializedTransaction: serializedTransaction.bytes.toBase64()
        )
        
        return response
        
    }
    
    private func createTransferInstruction(
        connection: Solana,
        sender: PublicKey,
        data: SolanaPaySpecification
    ) async throws -> TransactionInstruction {
        
        guard let splToken = data.splToken, var amount = data.amount else {
            throw TransferError.missingData            
        }
        
        // Get the mint account info and make sure that it exists
        
        let mintAccountInfo = try await connection.api.getAccountInfo(
            account: splToken.base58EncodedString,
            decodedTo: Mint.self
        )
        
        guard let mintAccountInfoData = mintAccountInfo.data.value, mintAccountInfoData.isInitialized else {
            throw TransferError.invalidMint
        }
        
        // Get the sender's ATA and check that the account exists and can send tokens
        
        let senderATA = try PublicKey.associatedTokenAddress(
            walletAddress: sender,
            tokenMintAddress: splToken
        ).get()
        
        let senderAccountInfo = try await connection.api.getAccountInfo(
            account: senderATA.base58EncodedString,
            decodedTo: AccountInfo.self
        )
        
        guard let senderAccountInfoData = senderAccountInfo.data.value, senderAccountInfoData.isInitialized, !senderAccountInfoData.isFrozen else {
            throw TransferError.invalidSenderAccount
        }
        
        // Get the recipient's ATA and check that the account exists and can receive tokens
        
        let recipientATA = try PublicKey.associatedTokenAddress(
            walletAddress: data.recipient,
            tokenMintAddress: splToken
        ).get()
        
        let recipientAccountInfo = try await connection.api.getAccountInfo(
            account: recipientATA.base58EncodedString,
            decodedTo: AccountInfo.self
        )
        
        guard let recipientAccountInfoData = recipientAccountInfo.data.value, recipientAccountInfoData.isInitialized, !recipientAccountInfoData.isFrozen else {
            throw TransferError.invalidRecipientAccount
        }
        
        // Convert input decimal amount to integer tokens according to the mint decimals
        amount = amount * pow(10, Double(mintAccountInfoData.decimals))
        
        // Check that the sender has enough tokens
        
        guard amount <= Double(senderAccountInfoData.lamports) else {
            throw TransferError.insufficientFunds
        }
        
        // Create an instruction to transfer SPL tokens, asserting the mint and decimals match
        
        let keys = [
            AccountMeta(publicKey: senderATA, isSigner: false, isWritable: true),
            AccountMeta(publicKey: splToken, isSigner: false, isWritable: false),
            AccountMeta(publicKey: recipientATA, isSigner: false, isWritable: true),
            AccountMeta(publicKey: sender, isSigner: true, isWritable: false),
            AccountMeta(publicKey: PublicKey(string: data.reference!)!, isSigner: false, isWritable: false)
        ]
        
        let lamports = UInt64(amount)
        let transferChecked: UInt8 = 12
        let decimals = mintAccountInfoData.decimals
        
        var data: [UInt8] = [transferChecked]
        
        data.append(contentsOf: lamports.bytes)
        data.append(decimals)
        
        let instruction = TransactionInstruction(
            keys: keys,
            programId: PublicKey.tokenProgramId,
            data: data
        )
        
        return instruction
        
    }
    
}
