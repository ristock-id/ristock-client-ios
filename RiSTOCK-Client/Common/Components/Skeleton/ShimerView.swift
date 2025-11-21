//
//  ShimerView.swift
//  RiSTOCK-Client
//
//  Created by Rico Tandrio on 21/11/25.
//

import SwiftUI

struct ShimmerView: ViewModifier {
    @State private var phase: CGFloat = 0

    let duration: Double = 1.5
    let speed: Double = 0.8

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    
                    let gradient = LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Token.gray100.swiftUIColor, location: 0),
                            .init(color: Token.gray50.swiftUIColor, location: 0.5),
                            .init(color: Token.gray100.swiftUIColor, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    gradient
                        .frame(width: width * 2 * phase)
                        .animation(
                            Animation.linear(duration: duration)
                                .repeatForever(autoreverses: false),
                            value: phase
                        )
                }
            }
            .onAppear {
                withAnimation {
                    phase = speed
                }
            }
            .background(Token.gray100.swiftUIColor)
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerView())
    }
}
