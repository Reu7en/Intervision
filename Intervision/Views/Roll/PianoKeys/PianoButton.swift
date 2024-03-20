//
//  PianoButton.swift
//  Intervision
//
//  Created by Reuben on 20/03/2024.
//

import SwiftUI

struct PianoButton: View {
    
    @Binding var showPiano: Bool
    
    let headerHeight: CGFloat
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                showPiano.toggle()
            }
        } label: {
            Image(systemName: showPiano ? "pianokeys" : "pianokeys.inverse")
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(showPiano ? Color.accentColor : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: headerHeight * 1.5, height: headerHeight * 1)
    }
}

#Preview {
    PianoButton(showPiano: Binding.constant(true), headerHeight: 50)
}
