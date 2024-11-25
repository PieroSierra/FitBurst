//
//  VideosView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct VideosView: View {
    var body: some View {
        VStack {
            Image(systemName: "video")
            Text("Videos")            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}

#Preview {
    VideosView()
}
