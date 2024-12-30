//
//  FirstRunView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct FirstRunView: View {
    @Binding var firstRunComplete: Bool
    @State private var selection : Int = 0
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().edgesIgnoringSafeArea(.all)
            VStack {
                TabView (selection: $selection) {
                    screen0.tag(0)
                    screen1.tag(1)
                    screen2.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
    }
    
    var screen0: some View {
        VStack (alignment: .center){
            Image("LogoSqClear")
                .resizable()
                .frame(width: 150, height:  150)
            
            Text("Welcome to FitBurst")
                .padding()
                .font(.custom("Futura Bold", fixedSize: 40))
                .multilineTextAlignment(.center)
            
            Text("FitBurst is the best wway to track your workouts.  Swipe for more.")
                .padding()
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.white)
        .padding(30)
        .frame(width:350, height: 500)
        .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(color: .limeAccentColor, radius: 10))
    }
    
    var screen1: some View {
        VStack (alignment: .center){
            Text("Things to know")
                .padding()
                .font(.custom("Futura Bold", fixedSize: 40))
                .multilineTextAlignment(.center)
            
            Text("FitBurst is the best wway to track your workouts.")
                .padding()
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.white)
        .padding(30)
        .frame(width:350, height: 500)
        .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(color: .limeAccentColor, radius: 10))
    }
    
    var screen2: some View {
        VStack (alignment: .center){
            Text("Mo Blah Blah")
                .padding()
                .font(.custom("Futura Bold", fixedSize: 40))
                .multilineTextAlignment(.center)
            
            Text("FitBurst is the best wway to track your workouts.")
                .padding()
                .font(.body)
                .multilineTextAlignment(.center)
            Spacer().frame(height:40)
            Button (action: {
                firstRunComplete = true
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                    Text("Let's go!")
                }
            }
            .buttonStyle(GrowingButtonStyle())
            
        }
        .foregroundColor(.white)
        .padding(30)
        .frame(width:350, height: 500)
        .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(color: .limeAccentColor, radius: 10))
    }
    
}

#Preview {
    FirstRunView(firstRunComplete: .constant(true))
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
