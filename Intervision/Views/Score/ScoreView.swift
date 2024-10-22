//
//  ScoreView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct ScoreView: View {
    
    @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel
    
    @Binding var presentedView: HomeView.PresentedView
    
    @StateObject var scoreViewModel: ScoreViewModel
    
    @State private var zoomLevel: CGFloat = 0.9
    @State private var showInspector: Bool = false
    
    var body: some View {
        if let pages = scoreViewModel.pages {
            GeometryReader { geometry in
                ScrollView([.vertical, .horizontal]) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<pages.count, id: \.self) { pageIndex in
                            PageView(
                                zoomLevel: $zoomLevel,
                                geometry: geometry,
                                bars: pages[pageIndex],
                                showScoreInformation: pageIndex == 0,
                                scoreTitle: scoreViewModel.scoreManager.score?.title ?? "",
                                scoreComposer: scoreViewModel.scoreManager.score?.composer ?? ""
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
            }
        }
    }
}

#Preview {
    ScoreView(presentedView: Binding.constant(.Score), scoreViewModel: ScoreViewModel(scoreManager: ScoreManager()))
        .environmentObject(DynamicSizingViewModel())
}
