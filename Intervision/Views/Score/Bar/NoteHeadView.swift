//
//  NoteHeadView.swift
//  Intervision
//
//  Created by Reuben on 15/02/2024.
//

import SwiftUI

struct NoteHeadView: View {
    
    let size: CGFloat
    let isHollow: Bool
    let isDotted: Bool
    
    init
    (
        size: CGFloat, 
        isHollow: Bool,
        isDotted: Bool
    ) {
        self.size = size
        self.isHollow = isHollow
        self.isDotted = isDotted
    }
    
    var body: some View {
        ZStack {
            if isHollow {
                Circle()
                    .stroke(.black, lineWidth: size / 5)
            } else {
                Circle()
                    .fill(Color.black)
            }
            
            if isDotted {
                Circle()
                    .scale(0.375)
                    .fill(Color.black)
                    .offset(x: size)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    NoteHeadView(size: 500, isHollow: true, isDotted: true)
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
