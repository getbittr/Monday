//
//  SpontaenousPaymentView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/28/23.
//

import SwiftUI
import WalletUI
import CodeScanner

struct SpontaneousPaymentView: View {
    @ObservedObject var viewModel: SpontaneousPaymentViewModel

    var body: some View {
        VStack {
            TextField("Enter payment amount", text: $viewModel.amount)
                .keyboardType(.decimalPad)
                .padding()
                
            Button("Confirm Payment") {
                viewModel.makePayment()
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .tint(Color.blue)
            .padding()
        }
    }
}
