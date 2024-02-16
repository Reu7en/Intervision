//
//  NoteHeadView.swift
//  Intervision
//
//  Created by Reuben on 15/02/2024.
//

import SwiftUI

struct NoteHeadView: View {
    
    let size: CGFloat
    let topColor: Color
    let bottomColor: Color
    let isHollow: Bool
    
    init(size: CGFloat, topColor: Color = Color.black, bottomColor: Color = Color.black, isHollow: Bool = false) {
        self.size = size
        self.topColor = topColor
        self.bottomColor = bottomColor
        self.isHollow = isHollow
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(topColor)
                .reverseMask {
                    Circle()
                        .scale(isHollow ? 0.7 : 0)
                }
            
            Circle()
                .fill(bottomColor)
                .clipShape(
                    Rectangle()
                        .offset(y: -size / 2)
                )
                .reverseMask {
                    Circle()
                        .scale(isHollow ? 0.7 : 0)
                }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    NoteHeadView(size: 500, topColor: Color.green, bottomColor: Color.blue, isHollow: true)
}

extension View {
  public func reverseMask<Mask: View>(
    alignment: Alignment = .center,
    @ViewBuilder _ mask: () -> Mask
  ) -> some View {
    self.mask {
      Rectangle()
        .overlay(alignment: alignment) {
          mask()
            .blendMode(.destinationOut)
        }
    }
  }
}
