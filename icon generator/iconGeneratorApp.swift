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
        
        Settings {
            SettingView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        FinderItem.temporaryDirectory.clear()
    }
    
}

extension FinderItem {
    
    static var output: FinderItem {
        .downloadsDirectory.with(subPath: "icon Output")
    }
    
}
