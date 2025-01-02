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
    @State private var showRipple: Int = 0
    @State private var buttonText = "Press and hold"
    
    init(firstRunComplete: Binding<Bool>) {
        _firstRunComplete = firstRunComplete
        // Customize UIPageControl appearance
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.limeAccentColor)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.limeAccentColor.opacity(0.3))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                TabView (selection: $selection) {
                    screen0.tag(0)
                    screen1.tag(1)
                    screen2.tag(2)
                }
                .tabViewStyle(.page)
             //   .accentColor(.limeAccentColor)
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
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
            
            Text("Swipe right to continue")
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
            
            Text("How to record a workout")
                .padding()
                .font(.custom("Futura Bold", fixedSize: 40))
                .multilineTextAlignment(.center)
            
            Text("To record a workout, **press and hold** the record button. Try it out!")
                .padding()
                .font(.body)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height:40)
            
            Button(action: { }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                    Text(buttonText)
                        .lineLimit(1)
                }
            }
            .padding(5)
            .buttonStyle(FillUpButtonStyle(
                buttonText: $buttonText,
                onComplete: { _, textBinding in
                    showRipple += 1
                    textBinding.wrappedValue = "Well done!"
                } ))
            
        }
        .foregroundColor(.white)
        .padding(30)
        .frame(width:350, height: 500)
        .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(color: .limeAccentColor, radius: 10))
        .modifier(RippleEffect(at: CGPoint(
            x: UIScreen.main.bounds.width / 2 - 30,
            y: UIScreen.main.bounds.height / 2 - 50 ), trigger: showRipple, amplitude: -22, frequency: 15, decay: 4, speed: 600))
    }
    
    var screen2: some View {
        VStack (alignment: .center){
            
            Text("Make FitBurst your own")
                .padding()
                .font(.custom("Futura Bold", fixedSize: 40))
                .multilineTextAlignment(.center)
            
            Text("You can customize up to six of your favorite workouts in **settings**.")
                .padding()
                .font(.body)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height:40)
            
            Button (action: {
                firstRunComplete = true
            }) {
                HStack {
                    Image(systemName: "hand.thumbsup.circle.fill")
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
