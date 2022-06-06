//
//  iconGeneratorApp.swift
//  icon generator
//
//  Created by Vaida on 12/10/21.
//

import SwiftUI
import Support

@main
struct iconGeneratorApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}

extension FinderItem {
    
    static var output: FinderItem {
        .downloads.with(subPath: "icon Output")
    }
    
}
