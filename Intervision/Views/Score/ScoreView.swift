//
//  ScoreView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct ScoreView: View {
    
    @State private var zoomLevel: CGFloat = 0.75
    @State private var pageCount: Int = 3
    @State private var contentOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView([.horizontal, .vertical]) {
                    VStack(spacing: 0) {
                        ForEach(0..<pageCount, id: \.self) { pageNumber in
                            PageView(geometry: Binding.constant(geometry), zoomLevel: $zoomLevel, pageNumber: pageNumber)
                                .offset(contentOffset)
                        }
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

#Preview {
    ScoreView()
}
