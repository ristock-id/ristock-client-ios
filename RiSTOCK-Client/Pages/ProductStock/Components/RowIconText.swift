//
//  RowIconText.swift
//  RiSTOCK-Client
//
//  Created by Andrea Octaviani on 24/11/25.
//

import SwiftUI
import Lottie

struct RowIconText: View {
    var icon: LottieAnimation? = nil
    let color: Color
    let text: String
    
    let number: Int
    
    @State var animatedNumber: Int = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if let icon {
                LottieView(animation: icon)
                    .playbackMode(.playing(.fromProgress(0, toProgress: 0.98, loopMode: .loop)))
                    .frame(width: 16, height: 16)
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            }
            
            (
                Text("\(animatedNumber) ") +
                Text(text)
            )
            .font(.system(size: 13))
        }
        .onAppear {
            animateNumberUp()
        }
    }
    
    func animateNumberUp() {
        animatedNumber = 0
        
        let duration: Double = 1.0
        let updateInterval: Double = 1.0 / 60.0
        
        let totalSteps = Int(duration / updateInterval)
        
        let incrementPerStep = Double(number) / Double(totalSteps)
        
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            currentStep += 1
            
            if currentStep > totalSteps {
                animatedNumber = number
                timer.invalidate()
                return
            }
            
            let currentValue = Double(currentStep) * incrementPerStep
            
            animatedNumber = Int(currentValue.rounded())
        }
    }
}


// MARK: - Preview
#if DEBUG
struct RowIconText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RowIconText(icon: RiSTOCKAnimation.fire, color: .green, text: "Success", number: 100)
            
            RowIconText(icon: nil, color: .red, text: "Error", number: 100)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
