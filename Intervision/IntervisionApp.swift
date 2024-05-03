//
//  IntervisionApp.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

@main
struct IntervisionApp: App {
    
    @StateObject var screenSizeViewModel = ScreenSizeViewModel()
    
    var body: some Scene {
        
        #if os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        #endif
        
        WindowGroup {
            GeometryReader { geometry in
                HomeView()
                    .environmentObject(screenSizeViewModel)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
}
