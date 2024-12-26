//
//  SettingsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

enum WorkoutType: Int32 {
    case strength = 0
    case run = 1
    case teamSport = 2
    case cardio = 3
    case yoga = 4
    case martialArts = 5
    
    var description: String {
        switch self {
        case .strength: return "Strength"
        case .run: return "Run"
        case .teamSport: return "Team Sport"
        case .cardio: return "Cardio"
        case .yoga: return "Yoga"
        case .martialArts: return "Martial Arts"
        }
    }
}

struct SettingsView: View {
    @AppStorage("workoutOneOverride") private var workoutOneOverride: String = "Strength"
    @AppStorage("workoutTwoOverride") private var workoutTwoOverride: String = "Run"
    @AppStorage("workoutThreeOverride") private var workoutThreeOverride: String = "Team Sport"
    @AppStorage("workoutFourOverride") private var workoutFourOverride: String = "Cardio"
    @AppStorage("workoutFiveOverride") private var workoutFiveOverride: String = "Yoga"
    @AppStorage("workoutSixOverride") private var workoutSixOverride: String = "Martial Arts"
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            VStack {
                Text("Settings")
                    .font(.custom("Futura Bold", size: 40))
                    .padding(.bottom, 20)
                    .foregroundStyle(.white)
                
                VStack (alignment: .leading){
                    Group {
                        
                        Text("Customize your workout types")
                        Divider().foregroundStyle(Color.white)
                        
                        Text("Workout type 1")
                        TextField("Strength", text: $workoutOneOverride)
                            .frame(width: 150, height:30)
                            .background(.white.opacity(0.3))
                            .cornerRadius(5)
                        Spacer()
                        Text("Workout type 2")
                        TextField("Run", text: $workoutTwoOverride)
                            .frame(width: 150, height:30)
                            .background(.white.opacity(0.3))
                            .cornerRadius(5)
                        Spacer()
                        Text("Workout type 3")
                        TextField("Team Sport", text: $workoutThreeOverride)
                            .frame(width: 150, height:30)
                            .background(.white.opacity(0.3))
                            .cornerRadius(5)
                        Spacer()
                        Text("Workout type 4")
                        TextField("Cardio", text: $workoutFourOverride)
                            .frame(width: 150, height:30)
                            .background(.white.opacity(0.3))
                            .cornerRadius(5)
                        Spacer()
                        Text("Workout type 5")
                        TextField("Yoga", text: $workoutFiveOverride)
                            .frame(width: 150, height:30)
                            .background(.white.opacity(0.3))
                            .cornerRadius(5)
                        Spacer()
                        Text("Workout type 6")
                        TextField("Martial Arts", text: $workoutSixOverride)
                            .frame(width: 150, height:30)
                            .background(.white.opacity(0.3))
                            .cornerRadius(5)
                        Spacer()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(35)
            }
        }
    }
}
#Preview {
    SettingsView()
}


/* Group {
 HStack {
 Text("Enter your name: ")
 Spacer()
 TextField("Your name", text: $userName)
 .frame(width: 150, height:30)
 .multilineTextAlignment(.trailing)
 .background(.white)
 //.overlay(RoundedRectangle(cornerRadius: 2).stroke(.gray))
 }
 
 Toggle("Example setting 1", isOn: $settingOne)
 Toggle("Example setting 2", isOn: $settingTwo)
 Toggle("Example setting 3", isOn: $settingThree)
 }
 .padding(.leading, 20)
 .padding(.trailing, 20)*/
