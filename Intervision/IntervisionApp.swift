//
//  IntervisionApp.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

@main
struct IntervisionApp: App {
    
    @StateObject var screenSizeViewModel = DynamicSizingViewModel(referenceViewSize: CGSize(width: 2560, height: 1440))
    
    @State private var isKeyboardVisible = false
    
    var body: some Scene {
        
        #if os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        #endif
        
        WindowGroup {
            GeometryReader { geometry in
                HomeView()
                    .environmentObject(screenSizeViewModel)
                    .frame(width: screenSizeViewModel.viewSize.width, height: screenSizeViewModel.viewSize.height, alignment: .center)
                    .onAppear {
                        #if os(iOS)
                        addKeyboardObservers()
                        #endif
                        
                        screenSizeViewModel.viewSize = geometry.size
                    }
                    .onChange(of: geometry.size) {
                        if !isKeyboardVisible {
                            screenSizeViewModel.viewSize = geometry.size
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .all)
                
                /*
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height))
                    
                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                }
                .stroke(.red)
                 */
            }
        }
    }
    
    #if os(iOS)
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            self.isKeyboardVisible = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.isKeyboardVisible = false
        }
    }
    #endif
}
