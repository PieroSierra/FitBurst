//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct HomeView: View {
    let gradientColors = Gradient(colors: [.blueBrandColor, .orangeBrandColor,.greenBrandColor,.blueBrandColor,.purpleBrandColor,.pinkBrandColor])
    
    var body: some View {
        VStack {
            Text("FitBurst")
            
            Image("LogoSqClear")
                .resizable()
                .frame(width:200, height:200)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button (action: {
                // insert action here
            }) {
                HStack {
                    Image(systemName: "dumbbell")
                    Text("Record Workout")
                }
            }.buttonStyle(GrowingButtonStyle())
            
           // GlowGradientButton(buttonText: "Record Workout")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}

#Preview {
    HomeView()
}
