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
        if let pages = scoreViewModel.pages {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ScrollView([.vertical, .horizontal]) {
                        LazyHStack(spacing: 0) {
                            ForEach(0..<pages.count, id: \.self) { pageIndex in
                                PageView(
                                    geometry: Binding.constant(geometry),
                                    zoomLevel: $zoomLevel,
                                    bars: pages[pageIndex]
                                )
                            }
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation(.easeInOut) {
                            presentedView = .Roll
                        }
                    } label: {
                        Image(systemName: "pianokeys")
                            .frame(width: 40, height: 20)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.trailing)
                    .padding(.top, 5)
                    .onChange(of: presentedView) { newValue, _ in
                        withAnimation(.easeInOut) {
                            presentedView = newValue
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScoreView(presentedView: Binding.constant(.Score), scoreViewModel: ScoreViewModel(scoreManager: ScoreManager()))
}
