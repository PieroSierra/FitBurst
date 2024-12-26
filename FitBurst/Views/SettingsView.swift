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
    @AppStorage("username") private var userName: String = ""
    @AppStorage("settingOne") private var settingOne: Bool = true
    @AppStorage("settingTwo") private var settingTwo: Bool = true
    @AppStorage("settingThree") private var settingThree: Bool = true
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            VStack {
                Text("Settings")
                    .font(.custom("Futura Bold", size: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                Group {
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
                .padding(.trailing, 20)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
#Preview {
    SettingsView()
}
