//
//  AppDelegate.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

#if os(macOS)
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Find the main window and maximise it
        if let window = NSApplication.shared.windows.first {
            withAnimation(.easeInOut) {
                window.maximiseToVisibleFrame()
            }
        }
    }
}

extension NSWindow {
    func maximiseToVisibleFrame() {
        guard let screen = self.screen else { return }
        let visibleFrame = screen.visibleFrame
        self.setFrame(visibleFrame, display: true, animate: true)
    }
}
#endif
