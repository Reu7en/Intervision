//
//  PianoKeysHeader.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

struct PianoKeysHeader: View {
    
    let headerHeight: CGFloat
    
    var body: some View {
        Spacer()
            .frame(height: headerHeight)
    }
}

#Preview {
    PianoKeysHeader(headerHeight: 0)
}
