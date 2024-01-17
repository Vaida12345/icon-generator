//
//  iconGeneratorApp.swift
//  icon generator
//
//  Created by Vaida on 12/10/21.
//

import SwiftUI
import Nucleus

@main
struct iconGeneratorApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var finderItems: [FinderItem] = []
    
    var body: some Scene {
        WindowGroup {
            ContentView(finderItems: $finderItems)
                .background(BlurredEffectView().ignoresSafeArea())
                .navigationTitle("")
                .frame(minWidth: 500)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Remove All") {
                    finderItems.removeAll()
                }
            }
        }
        
        Settings {
            SettingView()
                .frame(width: 400)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        try? FinderItem.temporaryDirectory.clear()
    }
    
}

extension FinderItem {
    
    static var output: FinderItem {
        FinderItem.downloadsDirectory.appending(path: "icon Output")
    }
    
}
