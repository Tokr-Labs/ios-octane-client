//
//  OctaneService.swift
//  SaucyCode
//
//  Created by Eric McGary on 10/10/22.
//

import Foundation
import SwiftUI

struct OctaneService {
    
    @AppStorage("octaneServer") var octaneServer = ""
    
    func send(serializedTransaction: String) async throws -> String? {
        
        let url = URL(string: octaneServer)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let data = try! JSONSerialization.data(withJSONObject: ["transaction": serializedTransaction])

        request.httpBody = data
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let (responseData, _) = try await URLSession.shared.data(for: request, delegate: nil)
        
        let json = try JSONSerialization.jsonObject(with: responseData) as? [String: String]
        
        return json?["txid"] as? String
        
    }
    
}
