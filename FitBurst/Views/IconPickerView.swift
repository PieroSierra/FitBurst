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
    @StateObject private var config = WorkoutConfiguration.shared
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.6
    
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
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Text("Choose a workout icon")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }

                ScrollView{
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                        ForEach(sportIcons, id: \.self) { iconName in
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
//                .padding()
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

#Preview {
    IconPickerView(showIconPickerView: .constant(true), workoutType: 0)
}
