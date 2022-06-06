//
//  CustomImage.swift
//  icon generator
//
//  Created by Vaida on 6/6/22.
//

import Foundation
import SwiftUI

struct CustomImage: View {
    
    @State var image: NSImage
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 120)
                .fill(.white)
                .frame(width: 1188, height: 1188)
                .shadow(radius: 20, x: 10, y: -15)
            
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 1130, height: 1130)
                .clipped()
                .cornerRadius(100)
        }
        .frame(width: 1350, height: 1350)
    }
}
