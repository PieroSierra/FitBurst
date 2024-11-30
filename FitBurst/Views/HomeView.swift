//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Tab
    
    let gradientColors = Gradient(colors: [.blueBrandColor, .orangeBrandColor,.greenBrandColor,.blueBrandColor,.purpleBrandColor,.pinkBrandColor])
    
    var body: some View {
        ScrollView {
            Text("FitBurst")
                .font(.title)
            HStack {
                Image("LogoSqClear")
                    .resizable()
                    .frame(width:200, height:200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack (alignment: .center) {
                    Text("18")
                        .font(.custom("Noteworthy", size: 60))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(0)
                        .padding(.top, -10)
                    Text ("workouts done")
                        .font(.custom("Noteworthy", size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(minWidth: 140, minHeight: 130)
                .background(Image("Blackboard").resizable().scaledToFill()).clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
            }
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
                    selectedTab = Tab.trophies
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
    HomeView(selectedTab: .constant(.home))
}
