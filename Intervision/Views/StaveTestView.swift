//
//  StaveTestView.swift
//  Intervision
//
//  Created by Reuben on 08/02/2024.
//

import SwiftUI

struct StaveTestView: View {
    
    @Binding var stave: Stave
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(0..<stave.rows.count, id: \.self) { i in
                    Rectangle()
                        .fill(stave.rows[i].isActive ? Color.white : Color.clear)
                        .frame(height: 15)
                        .border(stave.rows[i].isActive ? Color.black : Color.clear, width: 1)
                }
            }
            .border(Color.black, width: 2)
        }
    }
}

#Preview {
    StaveTestView(stave: Binding.constant(Stave(rowCount: 10, inactiveRows: 4, 5)))
}
