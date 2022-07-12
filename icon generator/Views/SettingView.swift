//
//  SettingView.swift
//  Icon Generator
//
//  Created by Vaida on 7/12/22.
//

import Foundation
import SwiftUI

struct SettingView: View {
    
    @AppStorage("generates into folder") private var generatesIntoFolder = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Generates into directory", isOn: $generatesIntoFolder)
            
            Group {
                if generatesIntoFolder {
                    Text("Generates the output files into Finder.")
                } else {
                    Text("Generate the output files, then you can drag the output files.")
                }
            }
            .font(.callout)
            .foregroundColor(.secondary)
        }
        .padding()
    }
    
}
