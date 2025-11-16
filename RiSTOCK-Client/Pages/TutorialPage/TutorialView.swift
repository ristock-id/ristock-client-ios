//
//  TutorialView.swift
//  RiSTOCK-Client
//
//  Created by Jehoiada Wong on 15/11/25.
//

import SwiftUI

struct TutorialView: View {
    var nextAction: () -> Void
    private let captionList: [Text] = [
        Text("Buka aplikasi ") +
        Text("RISTOCK")
            .fontWeight(.bold) +
        Text(" di laptop"),
        
        Text("Buka halaman ") +
        Text("“Hubungkan HP”")
            .fontWeight(.bold),
        
        Text("Arahkan kamera dan ") +
        Text("scan ")
            .italic()
            .fontWeight(.bold) +
        Text("QR code")
            .fontWeight(.bold)
    ]
    
    var body: some View{
        NavigationStack {
            VStack {
                Spacer()
                Text("Scan QR Code")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.bottom, 50)
                
                Image("qr_tutorial")
                    .resizable()
                    .frame(width: 145, height: 145)
                    .padding(.bottom, 50)
                Stepper(captionList: captionList)
                    .padding(.bottom, 130)
                Button {
                    nextAction()
                } label:{
                    Text("Scan QR Code")
                        .padding(15)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .foregroundStyle(Token.primary700.swiftUIColor)
                                .padding(.horizontal)
                        )
                }
            }
        }
    }
}
