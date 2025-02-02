//
//  NodeIDView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import SwiftUI
import WalletUI

struct NodeIDView: View {
    @ObservedObject var viewModel: NodeIDViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingNodeIDErrorAlert = false
    @State private var showingInputSheet = false
    @State private var messageToSign = "I confirm I'm the sole owner of the bitcoin address I provided and I will be sending my own funds to bittr. Order: NINJXUPE7BNXYVYEXWVI1B1RT9CAE3YK. IBAN: "
    @State private var inputIBAN = "NL27ABNA0451135725"
    @State private var signedMessage: String = ""
    @State private var messageToBeSigned: String = ""
    @State private var isSignatureCopied = false
    @State private var showSignatureCheckmark = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                VStack(spacing: 20.0) {
                    if !signedMessage.isEmpty {
                        HStack(alignment: .center) {
                            Text("Signature: \(signedMessage)")
                                .frame(width: 200, height: 50)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            Button {
                                UIPasteboard.general.string = signedMessage
                                isSignatureCopied = true
                                showSignatureCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isSignatureCopied = false
                                    showSignatureCheckmark = false
                                }
                            } label: {
                                HStack {
                                    withAnimation {
                                        Image(systemName: showSignatureCheckmark ? "checkmark" : "doc.on.doc")
                                            .font(.subheadline)
                                    }
                                }
                                .bold()
                                .foregroundColor(viewModel.networkColor)
                            }
                        }
                        .padding(.horizontal)
                    }
                    if !messageToBeSigned.isEmpty {
                        HStack(alignment: .center) {
                            Text("Message: \(messageToBeSigned)")
                                .frame(width: 200, height: 50)
//                                .truncationMode(.middle)
                                .lineLimit(3)
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            Button {
                                UIPasteboard.general.string = messageToBeSigned
                                isSignatureCopied = true
                                showSignatureCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isSignatureCopied = false
                                    showSignatureCheckmark = false
                                }
                            } label: {
                                HStack {
                                    withAnimation {
                                        Image(systemName: showSignatureCheckmark ? "checkmark" : "doc.on.doc")
                                            .font(.subheadline)
                                    }
                                }
                                .bold()
                                .foregroundColor(viewModel.networkColor)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(viewModel.networkColor)
                    HStack(alignment: .center) {
                        Text(viewModel.nodeID)
                            .frame(width: 200, height: 50)
                            .truncationMode(.middle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Button {
                            UIPasteboard.general.string = viewModel.nodeID
                            isCopied = true
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                                showCheckmark = false
                            }
                        } label: {
                            HStack {
                                withAnimation {
                                    Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                        .font(.subheadline)
                                }
                            }
                            .bold()
                            .foregroundColor(viewModel.networkColor)
                        }
                    }
                    .padding(.horizontal)

                    // "Sign Message" button
                    Button(action: {
                        showingInputSheet = true
                    }) {
                        HStack {
                            Image(systemName: "pencil.tip.crop.circle")
                            Text("Sign Message")
                        }
                        .frame(width: 150)
                        .padding(.all, 8)
                    }
                    .sheet(isPresented: $showingInputSheet, onDismiss: {
                        if !inputIBAN.isEmpty {
                            messageToSign += inputIBAN // append IBAN to message
                            Task {
                                do {
                                    let signedMessageResult = try await viewModel.signMessage(message: messageToSign)
                                    DispatchQueue.main.async {
                                        signedMessage = signedMessageResult // set signed message
                                        print("Signature: \(signedMessage)")
                                        messageToBeSigned = messageToSign
                                        print("Message: \(messageToSign)")
                                    }
                                } catch {
                                    print("Error signing message: \(error)")
                                    // handle error here
                                }
                            }
                        }
                    }) {
                        VStack {
                            Text("Enter IBAN")
                            TextField("IBAN", text: $inputIBAN)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                            Button("Sign Message") {
                                showingInputSheet = false
                            }
                            .padding()
                        }
                    }

                }
                .padding()
                .navigationTitle("Node ID")
                .alert(isPresented: $showingNodeIDErrorAlert) {
                    Alert(
                        title: Text(viewModel.nodeIDError?.title ?? "Unknown"),
                        message: Text(viewModel.nodeIDError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.nodeIDError = nil
                        }
                    )
                }
                .onReceive(viewModel.$nodeIDError) { errorMessage in
                    if errorMessage != nil {
                        showingNodeIDErrorAlert = true
                    }
                }
                .onAppear {
                    Task {
                        viewModel.getNodeID()
                        viewModel.getColor()
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct NodeIDView_Previews: PreviewProvider {
    static var previews: some View {
        NodeIDView(viewModel: .init())
        NodeIDView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
