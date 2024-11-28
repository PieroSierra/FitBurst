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
        ScrollView {
            Text("FitBurst").font(.title)
            Image("LogoSqClear")
                .resizable()
                .frame(width:200, height:200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text("18 workouts complete!").font(.body)
            Spacer().frame(height: 20)
            Button (action: {
                // insert action here
            }) {
                HStack {
                    Image(systemName: "dumbbell")
                    Text("Record Workout")
                }
            }.buttonStyle(GrowingButtonStyle())
            
            Spacer().frame(height: 20)
            
            
            HStack {
                Text("Your trophies:")
                Spacer()
            }.padding()
            
            TrophyBox(height: 150, scrollHorizontally: true)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            HStack {
                Spacer()
                Button (action: {
                    // insert action here
                }) {
                    HStack {
                        Image(systemName: "medal")
                        Text("See all")
                    }
                }.buttonStyle(GrowingButtonStyle())
                    .padding(0)
                    .padding(.trailing, 20)
            }
            
        }
        //     .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}

#Preview {
    HomeView()
}
