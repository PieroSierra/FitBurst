//
//  IconPickerView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 26/12/2024.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var showIconPickerView: Bool
    let workoutType: Int32
    let textHint: String
    @StateObject private var config = WorkoutConfiguration.shared
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.6
    @State private var searchText = ""
    
    let sportIcons = [
        "dumbbell.fill",
        "tennis.racket",
        "figure.pickleball",
        "figure.racquetball",
        "soccerball",
        "tennisball.fill",
        "american.football.fill",
        "figure.jumprope",
        "skis.fill",
        "figure.tennis",
        "figure.run",
        "figure.roll",
        "figure.highintensity.intervaltraining",
        "figure.squash",
        "surfboard.fill",
        "figure.walk.motion",
        "figure.snowboarding",
        "figure.baseball",
        "figure.surfing",
        "figure.american.football",
        "figure.archery",
        "sportscourt.fill",
        "figure.strengthtraining.traditional",
        "figure.australian.football",
        "rugbyball.fill",
        "hockey.puck.fill",
        "figure.field.hockey",
        "figure.step.training",
        "volleyball.fill",
        "figure.climbing",
        "figure.dance",
        "figure.fencing",
        "baseball.fill",
        "figure.disc.sports",
        "figure.skiing.downhill",
        "figure.kickboxing",
        "basketball.fill",
        "snowboard.fill",
        "figure.martial.arts",
        "figure.equestrian.sports",
        "figure.skiing.crosscountry",
        "figure.strengthtraining.functional",
        "figure.rugby",
        "figure.yoga",
        "figure.walk",
        "cricket.ball.fill",
        "skateboard.fill",
        "figure.handball",
        "figure.run.treadmill",
        "figure.cross.training",
        "figure.bowling",
        "figure.pilates",
        "figure.mind.and.body",
        "figure.golf",
        "figure.cricket",
        "figure.volleyball",
        "figure.gymnastics",
        "figure.lacrosse",
        "figure.barre",
        "figure.outdoor.rowing",
        "figure.boxing",
        "figure.curling",
        "figure.elliptical",
        "figure.hiking",
        "figure.basketball",
        "figure.outdoor.cycle",
        "figure.rolling",
        "figure.indoor.soccer",
        "figure.indoor.cycle",
        "figure.badminton",
        "figure.cooldown",
        "figure.table.tennis"
    ]
    
    init(showIconPickerView: Binding<Bool>, workoutType: Int32, textHint: String) {
        self._showIconPickerView = showIconPickerView
        self.workoutType = workoutType
        self.textHint = textHint
        
        // Split textHint into words and check if all words appear in any icon
        let searchWords = textHint.lowercased().split(separator: " ")
        
       let hasMatches = sportIcons.contains { icon in
            let matches = searchWords.allSatisfy { word in
                let contains = icon.lowercased().contains(word)
                return contains
            }
            return matches
        }
        
        self._searchText = State(initialValue: hasMatches ? textHint : "")
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Choose a workout icon")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }.padding(.leading, 4)
            
                ScrollView{
                    SearchBar(searchText: $searchText)
                        .padding(.bottom, 9)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                     
                        ForEach(sportIcons.filter { icon in
                            if searchText.isEmpty { return true }
                            let searchWords = searchText.lowercased().split(separator: " ")
                            return searchWords.allSatisfy { word in
                                icon.lowercased().contains(word)
                            }
                        }, id: \.self) { iconName in
                            Button {
                                config.setIcon(iconName, for: workoutType)
                                showIconPickerView = false
                            } label: {
                                Image(systemName: iconName)
                                    .font(.title)
                                    .foregroundStyle(Color.black)
                                    .frame(width: 60, height: 60)
                                    .background(config.getIcon(for: workoutType) == iconName ? Color.limeAccentColor : Color.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding(30)
            .frame(width:350, height:400)
            .overlay(dismissButton, alignment: .topTrailing)
            .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(color: .limeAccentColor, radius: 10))
            .scaleEffect(scale)
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
        }
        .onTapGesture {
            showIconPickerView = false
        }
    }
    
    private var dismissButton: some View {
        Button(action: {
            showIconPickerView = false
        }) {
            Image(systemName: "xmark.circle")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .padding(25)
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        TextField("Search", text: $searchText)
            .textFieldStyle(.plain)
            .padding (10)
            .background(.white)
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
            .padding(4)
            .overlay(
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black)
                        .padding(.horizontal, 5)
                        .opacity(
                            searchText.isEmpty ? 0 : 1)
                }, alignment: .trailing
            )
    }
}


#Preview {
    IconPickerView(showIconPickerView: .constant(true), workoutType: 0, textHint: "")
}
