//
//  PeerViewModel.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/29/23.
//

import SwiftUI
import LDKNode

class PeerViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var peerViewError: MondayError?
    @Published var networkColor = Color.gray
    @Published var nodeId: PublicKey = ""
    @Published var isProgressViewShowing: Bool = false
    
    func connect(
        nodeId: PublicKey,
        address: String
    ) async {
        do {
            try await LightningNodeService.shared.connect(
                nodeId: nodeId,
                address: address,
                persist: true
            )
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.peerViewError = .init(title: errorString.title, detail: errorString.detail)
                self.isProgressViewShowing = false
            }
        } catch {
            DispatchQueue.main.async {
                self.peerViewError = .init(title: "Unexpected error", detail: error.localizedDescription)
                self.isProgressViewShowing = false
            }
        }
        
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}
