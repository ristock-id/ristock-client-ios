//
//  AlertRistock.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 21/11/25.
//

import SwiftUI

struct AlertRistock: ViewModifier {
    @Binding var isPresented: Bool
    
    let title: String
    let message: String
    let image: Image?
    let onConfirmText: String = "Confirm"
    let onConfirm: () -> Void
    let onCancelText: String = "Cancel"
    let onCancel: () -> Void
    
    // Added explicit initializer to align with modifier usage
    init(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        image: Image? = nil,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.image = image
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut, value: isPresented)
                
                VStack(alignment: .center, spacing: 20) {
                    Spacer().frame(height: 10)
                    
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    
                    Text(title)
                        .font(.customFont(size: 16, weight: .bold))
                        .padding(.top, 20)
                        .padding(.horizontal, 30)
                    
                    Text(message)
                        .font(.customFont(size: 13, weight: .regular))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    HStack {
                        Button(action: onCancel) {
                            Text(onCancelText)
                                .foregroundColor(Token.primary600.swiftUIColor)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Token.primary50.swiftUIColor)
                                .cornerRadius(24)
                        }
                        
                        Button(action: onConfirm) {
                            Text(onConfirmText)
                                .foregroundColor(Token.white.swiftUIColor)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Token.primary600.swiftUIColor)
                                .cornerRadius(24)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 10)
                }
                .padding()
                .background(Token.white.swiftUIColor)
                .cornerRadius(24)
                .padding(.horizontal, 40)
                .animation(.easeInOut, value: isPresented)
            }
        }
    }
}

extension View {
    func alertRistock(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        image: Image? = nil,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(
            AlertRistock(
                isPresented: isPresented,
                title: title,
                message: message,
                image: image,
                onConfirm: onConfirm,
                onCancel: onCancel
            )
        )
    }
}

// MARK: Preview
#Preview {
    EmptyView()
        .alertRistock(
            isPresented: .constant(true),
            title: "Hapus Produk",
            message: "Apakah Anda yakin ingin menghapus produk ini dari daftar?",
            image: Image(uiImage: RiSTOCKIcon.logoutIcon.image),
            onConfirm: { print("Confirmed") },
            onCancel: { print("Cancelled") }
        )
}
