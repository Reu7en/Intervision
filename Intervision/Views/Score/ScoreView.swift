//
//  ScoreView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct ScoreView: View {
    
    @Binding var presentedView: HomeView.PresentedView
    
    @StateObject var scoreViewModel: ScoreViewModel
    
    @State private var zoomLevel: CGFloat = 0.75
    @State private var showInspector: Bool = false
    
    var body: some View {
        if let score = scoreViewModel.score,
           let parts = score.parts {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ScrollView([.vertical, .horizontal]) {
                        HStack(spacing: 0) {
                            ForEach(0..<parts.count, id: \.self) { partIndex in
                                PageView(geometry: Binding.constant(geometry), zoomLevel: $zoomLevel, bars: parts[partIndex].bars, part: parts[partIndex])
                            }
                        }
                    }
                    
                    if showInspector {
                        ScoreInspectorView(presentedView: $presentedView)
                            .frame(width: geometry.size.width / 10)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            showInspector.toggle()
                        }
                    } label: {
                        Image(systemName: "gear.circle")
                            .frame(width: 40, height: 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(showInspector ? Color.accentColor : Color.clear)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.trailing)
                    .padding(.top, 5)
                }
            }
        }
    }
}

#Preview {
    ScoreView(presentedView: Binding.constant(.Score), scoreViewModel: ScoreViewModel(score: nil))
        .environmentObject(ScoreViewModel(score: nil))
}
