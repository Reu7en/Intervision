//
//  IntervisionApp.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

@main
struct IntervisionApp: App {
    var body: some Scene {
        
        @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
        WindowGroup {
            MainWindowView()
                .onAppear {
                    TestLoad.testLoad()
                }
        }
    }
}
