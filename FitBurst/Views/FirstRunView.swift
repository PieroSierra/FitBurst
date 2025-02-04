//
//  FirstRunView.swift
//  FitBurst
//
//  Created by Nikola Sierra on 24/11/2024.
//

import SwiftUI

struct FirstRunView: View {
    @Binding var firstRunComplete: Bool
    @State private var selection: Int = 0
    @State private var showRipple: Int = 0
    @State private var buttonText = "Press and hold"
    @Bindable private var appState = AppState.shared // Keep Bindable as we change the background
    
    init(firstRunComplete: Binding<Bool>) {
        _firstRunComplete = firstRunComplete
        // Customize UIPageControl appearance
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.limeAccentColor)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.limeAccentColor.opacity(0.3))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            TabView(selection: $selection) {
                screen0
                    .tag(0)
                screen1
                    .tag(1)
                screen2
                    .tag(2)
                screen3
                    .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
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
        .frame(width: UIScreen.main.bounds.width - 40, height: 500)
        .background(Color.black.opacity(1).clipShape(RoundedRectangle(cornerRadius: 40))
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
        .frame(width: UIScreen.main.bounds.width - 40, height: 500)
        .background(Color.black.opacity(1).clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(color: .limeAccentColor, radius: 10))
        .modifier(RippleEffect(at: CGPoint(
            x: UIScreen.main.bounds.width / 2 - 30,
            y: UIScreen.main.bounds.height / 2 - 50 ), trigger: showRipple, amplitude: -22, frequency: 15, decay: 4, speed: 600))
    }
    
    var screen2: some View {
        // Create base content
        let content = VStack(alignment: .center) {
            ScrollView {
                Text("Set a mood")
                    .padding()
                    .font(.custom("Futura Bold", fixedSize: 40))
                    .multilineTextAlignment(.center)

                Text("Pick a background for your workouts:")
                    .padding()
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Spacer()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(appState.backgroundOptions, id: \.displayName) { option in
                        Button(action: {
                            showRipple += 1
                            appState.currentBackground = option.displayName
                        }) {
                            ZStack {
                                Image(option.assetName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width/4.5)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .limeAccentColor, radius: 5)
                                Text(option.displayName)
                                    .foregroundColor(.white)
                                    .padding(10)
                            }
                            .buttonStyle(GrowingButtonStyle())
                        }
                    }
                }
            }
        }
        .foregroundColor(.white)
        .padding(30)
        
        // Apply overlays and background separately
        return content
            .overlay(
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors:[Color.black.opacity(0.0), Color.black.opacity(1)]),
                        startPoint: .bottom,
                        endPoint: .top
                    ))
                    .frame(width: UIScreen.main.bounds.width-70, height: 20)
                    .padding(.top, 30)
                , alignment: .top)
            .overlay(
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors:[Color.black.opacity(0.0), Color.black.opacity(1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: UIScreen.main.bounds.width-70, height: 20)
                    .padding(.bottom, 30)
                , alignment: .bottom)
            .frame(width: UIScreen.main.bounds.width - 40, height: 500)
            .background(
                Color.black.opacity(1)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .shadow(color: .limeAccentColor, radius: 10)
            )
            .modifier(RippleEffect(
                at: CGPoint(
                    x: UIScreen.main.bounds.width / 2,
                    y: UIScreen.main.bounds.height / 2
                ),
                trigger: showRipple,
                amplitude: -22,
                frequency: 15,
                decay: 4,
                speed: 600
            ))
    }
    
    
    var screen3: some View {
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
        .frame(width: UIScreen.main.bounds.width - 40, height: 500)
        .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
            .shadow(color: .limeAccentColor, radius: 10))
    }
    
}

#Preview {
    FirstRunView(firstRunComplete: .constant(false))
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
