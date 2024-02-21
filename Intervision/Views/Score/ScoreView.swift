//
//  ScoreView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct ScoreView: View {
    
    @StateObject var scoreViewModel: ScoreViewModel
    @State private var zoomLevel: CGFloat = 0.9
    @State private var pageCount: Int = 10
    @State private var contentOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero
    
    var body: some View {
        if let score = scoreViewModel.score,
           let parts = score.parts {
            GeometryReader { geometry in
                ZStack {
                    ScrollView([.horizontal, .vertical]) {
                        if scoreViewModel.viewType == .Vertical {
                            VStack(spacing: 0) {
                                
                            }
                        } else if scoreViewModel.viewType == .Horizontal {
                            HStack(spacing: 0) {
                                ForEach(0..<parts.count, id: \.self) { partIndex in
                                    PageView(geometry: Binding.constant(geometry), zoomLevel: $zoomLevel, bars: parts[partIndex].bars, part: parts[partIndex])
                                        .offset(contentOffset)
                                }
                            }
                        } else if scoreViewModel.viewType == .VerticalWide {
                            
                        }
                    }
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            contentOffset = CGSize(width: accumulatedOffset.width + gesture.translation.width, height: accumulatedOffset.height + gesture.translation.height)
                        }
                        .onEnded { _ in
                            accumulatedOffset = contentOffset
                        }
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview {
    ScoreView(scoreViewModel: ScoreViewModel(score: nil))
        .environmentObject(ScoreViewModel(score: nil))
}
