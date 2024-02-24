//
//  RollView.swift
//  Intervision
//
//  Created by Reuben on 23/02/2024.
//

import SwiftUI

struct RollView: View {
    
    let scale: CGFloat = 1.0
    let octaves = 9
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.vertical, .horizontal]) {
                LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        VStack(spacing: 0) {
                            let rows = octaves * 12
                            
                            ForEach(0..<rows, id: \.self) { rowIndex in
                                Rectangle()
                                    .fill([1, 3, 5, 8, 10].contains(rowIndex % 12) ? Color.gray : Color.white)
                                    .frame(height: geometry.size.height / CGFloat(rows / 2))
                                    .border(Color.gray.opacity(0.5))
                            }
                        }
                        .frame(width: geometry.size.width * 3)
                    } header: {
                        PianoKeysView(geometry: geometry, octaves: octaves)
                    }
                }
            }
        }
    }
}

#Preview {
    RollView()
}
