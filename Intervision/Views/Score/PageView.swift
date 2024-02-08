//
//  PageView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct PageView: View {
    
    @Binding var geometry: GeometryProxy
    @Binding var zoomLevel: CGFloat
    let pageNumber: Int
    let aspectRatio: CGFloat = 210 / 297 // A4 paper aspect ratio
    
    var body: some View {
        ZStack {
            let width = geometry.size.height * aspectRatio * zoomLevel
            let height = geometry.size.height * zoomLevel
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: width, height: height)
                .padding()
            
//            Text("Page \(pageNumber + 1)")
//                .font(.title)
//                .foregroundColor(Color.black)
            
            VStack {
                StaveTestView(stave: Binding.constant(Stave(rowCount: 5)))
            }
            .frame(width: width, height: height)
            .padding()
        }
    }
}

#Preview {
    GeometryReader { geometry in
        PageView(geometry: Binding.constant(geometry), zoomLevel: Binding.constant(1.0), pageNumber: 0)
    }
}
