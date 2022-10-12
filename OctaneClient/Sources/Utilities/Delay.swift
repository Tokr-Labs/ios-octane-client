//
//  Delay.swift
//  RhoveBeta
//
//  Created by Eric on 4/1/21.
//

import Foundation
import Combine

@discardableResult func delay(interval: TimeInterval, block: @escaping () -> Void) -> Operation {

    let operation = Operation()
    operation.completionBlock = block
    
    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
       
        guard !operation.isCancelled else { return }
        operation.completionBlock?()
        
    }
    
    return operation

}
