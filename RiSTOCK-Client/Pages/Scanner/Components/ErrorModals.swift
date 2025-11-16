//
//  ErrorModals.swift
//  RiSTOCK-Client
//
//  Created by Andrea Octaviani on 15/11/25.
//

import SwiftUI

// MARK: - 1. ErrorModal (Komponen Wrapper)
struct ErrorModal: View {
    
    @Binding var isPresented: Bool
    let errorLogo: String
    let errorTitle: String
    let errorMessage: String
    let actionButtonTitle: String
    let cancel: Bool
    let action: () -> Void
    
    init(isPresented: Binding<Bool>,
         errorLogo: String,
         errorTitle: String,
         errorMessage: String,
         actionButtonTitle: String,
         cancel: Bool,
         action: @escaping () -> Void)
    {
        self._isPresented = isPresented
        self.errorLogo = errorLogo
        self.errorTitle = errorTitle
        self.errorMessage = errorMessage
        self.actionButtonTitle = actionButtonTitle
        self.cancel = cancel
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)
            
            // Kartu pop-up
            ErrorPopover(
                isPresented: $isPresented,
                errorLogo: errorLogo,
                errorTitle: errorTitle,
                errorMessage: errorMessage,
                actionButtonTitle: actionButtonTitle,
                cancel: cancel,
                action: action
            )
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .ignoresSafeArea()
    }
}

// MARK: - 2. ErrorPopover (Komponen Inti / Kartu)
struct ErrorPopover: View {
    
    @Binding var isPresented: Bool
    
    let errorLogo: String
    let errorTitle: String
    let errorMessage: String
    let actionButtonTitle: String
    let cancel: Bool
    let action: () -> Void
        
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. Logo
            Image(errorLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 140)
                .padding(.top, 24)
            
            // 2. Judul
            Text(errorTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            // 3. Pesan (Hanya tampil jika tidak kosong)
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            
            // 4. Baris Tombol
            if cancel {
                // Tampilkan 2 tombol (Cancel & Action)
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation { isPresented = false }
                    }) {
                        Text("Cancel")
                            .fontWeight(.regular)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primary50)
                            .foregroundColor(.primary600)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {
                        action()
                    }) {
                        Text(actionButtonTitle)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.primary600)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
            } else {
                // Tampilkan 1 tombol (Action Saja)
                Button(action: {
                    action()
                    withAnimation { isPresented = false }
                }) {
                    Text(actionButtonTitle)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.primary600)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .padding(.top, errorMessage.isEmpty ? 12 : 0)
            }
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.2), radius: 10)
        .padding(.horizontal, 40)
    }
}
