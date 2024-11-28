//
//  SettingsView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("username") private var userName: String = ""
    @AppStorage("settingOne") private var settingOne: Bool = true
    @AppStorage("settingTwo") private var settingTwo: Bool = true
    @AppStorage("settingThree") private var settingThree: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .imageScale(.large)
                
                Text("Settings")
                    .font(.title)
                    .bold()
            }
            Group {
                HStack {
                    Text("Enter your name: ")
                    Spacer()
                    TextField("Your name", text: $userName)
                        .frame(width: 200, height:30)
                        .multilineTextAlignment(.trailing)
                        .overlay(RoundedRectangle(cornerRadius: 2)
                            .stroke(.gray))
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
        .background(Color.greenBrandColor)
    }
}

#Preview {
    SettingsView()
}
