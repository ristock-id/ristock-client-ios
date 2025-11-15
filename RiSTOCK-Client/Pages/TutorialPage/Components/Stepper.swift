//
//  Stepper.swift
//  RiSTOCK-Client
//
//  Created by Jehoiada Wong on 15/11/25.
//

import SwiftUI


struct Stepper: View {
    var captionList: [Text]
    
    private let primaryColor = Token.primary700.swiftUIColor
    private let circleSize: CGFloat = 25
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(captionList.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 15) {
                    // Timeline Dot & Line Column
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(primaryColor)
                                .frame(width: circleSize, height: circleSize)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        // Vertical Connector Line
                        if index < captionList.count - 1 {
                            Rectangle()
                                .fill(primaryColor)
                                .frame(width: 4, height: 26)
                        }
                    }
                    .frame(width: circleSize)
                    
                    VStack(alignment: .leading) {
                        captionList[index]
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 1)
                }
            }
        }
        .padding()
    }
}

#Preview {
    Stepper(
        captionList: [
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
    )
}
