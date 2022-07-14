//
//  SettingView.swift
//  Icon Generator
//
//  Created by Vaida on 7/12/22.
//

import Foundation
import SwiftUI
import Support

struct SettingView: View {
    
    @AppStorage("mode") private var mode: ProcessMode = .export
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker("Destination", selection: $mode, options: ProcessMode.allCases)
            
            Group {
                switch mode {
                case .export:
                    Text("Generates the output files into Finder.")
                case .noneDestination:
                    Text("Generate the output files, then you can drag the output files.")
                case .auto:
                    Text("Generate the output files, then you can drag the output files.")
                }
            }
            .font(.callout)
            .foregroundColor(.secondary)
        }
        .padding()
    }
    
}
