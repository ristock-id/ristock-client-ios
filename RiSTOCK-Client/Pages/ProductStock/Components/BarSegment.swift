//
//  SegmentedBar.swift
//  RiSTOCK
//
//  Created by Rico Tandrio on 21/11/25.
//

import SwiftUI

struct BarSegment: Identifiable {
    let id = UUID()
    let percentage: Double
    let color: Color
}

struct SegmentedBar: View {
    let segments: [BarSegment]
    let height: CGFloat = 8.0
    let spacing: CGFloat = 2.0
    
    var body: some View {
        GeometryReader { geo in
            let totalSpacing = CGFloat(segments.count - 1) * spacing
            let availableWidthForBars = geo.size.width - totalSpacing
            
            HStack(alignment: .firstTextBaseline, spacing: spacing) {
                ForEach(segments) { segment in
                    PercentageBar(
                        color: segment.color,
                        width: availableWidthForBars * segment.percentage
                    )
                }
            }
        }
        .frame(height: height)
    }
}

struct PercentageBar: View {
    var color: Color
    var height: CGFloat = 8.0
    var width: CGFloat
    
    @State private var animatedWidth: CGFloat = 0.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10.0)
            .fill(color)
            .frame(height: height)
            .frame(width: animatedWidth, alignment: .leading)
            .onAppear {
                withAnimation(.snappy(duration: 1.0)) {
                    animatedWidth = width
                }
            }
    }
}

// MARK: - Preview
#if DEBUG
struct SegmentedBar_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedBar(segments: [
            BarSegment(percentage: 0.5, color: .red),
            BarSegment(percentage: 0.3, color: .green),
            BarSegment(percentage: 0.2, color: .blue)
        ])
        .frame(height: 20)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif