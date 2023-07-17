//
//  SendViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LDKNode

class SpontaneousPaymentViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var nodeId: String = "026d74bf2a035b8a14ea7c59f6a0698d019720e812421ec02762fdbf064c3bc326"
    @Published var paymentHash: PaymentHash?
    @Published var sendConfirmationViewError: (title: String, detail: String)?

    func makePayment() {
        DispatchQueue.global().async {
            do {
                guard let amountSat = UInt64(self.amount) else {
                    DispatchQueue.main.async {
                        self.sendConfirmationViewError = (title: "Invalid amount", detail: "Please enter a valid amount")
                    }
                    return
                }
                let amountMsat = amountSat * 1000
                print("amountMsat: \(amountMsat)") // This will print the value of amountMsat
                let paymentHash = try LightningNodeService.shared.sendSpontaneousPayment(amountMsat: amountMsat, nodeId: self.nodeId)
                DispatchQueue.main.async {
                    print("paymentHash: \(paymentHash)") // This will print the payment hash if successful
                    self.paymentHash = paymentHash
                }
            } catch let error as NodeError {
                let errorString = self.handleNodeError(error)
                DispatchQueue.main.async {
                    print("Node Error: \(error)")
                    self.sendConfirmationViewError = (title: errorString.title, detail: errorString.detail)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Unexpected Error: \(error)")
                    self.sendConfirmationViewError = (title: "Unexpected error", detail: error.localizedDescription)
                }
            }
        }
    }

    private func handleNodeError(_ error: NodeError) -> (title: String, detail: String) {
        // Return a title and detail string based on the error
        // For the sake of simplicity, this function returns a generic message
        return (title: "Node Error", detail: error.localizedDescription)
    }
}



