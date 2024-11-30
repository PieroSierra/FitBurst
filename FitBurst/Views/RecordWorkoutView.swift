//
//  RecordWorkoutView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 30/11/2024.
//

import SwiftUI

struct RecordWorkoutView: View {
    var body: some View {
        
        
        VStack {
            HStack {
                Button (action: {
                })
                {
                    HStack {
                        Image(systemName: "dumbbell.fill")
                        Text("Weights")
                    }
                }
                .buttonStyle(GrowingButtonStyle())
                
                Button (action: {
                })
                {
                    HStack {
                        Image(systemName: "figure.run.circle.fill")
                        Text("Running")
                    }
                }
                .buttonStyle(GrowingButtonStyle())
            }
            HStack {
                Button (action: {
                })
                {
                    HStack {
                        Image(systemName: "soccerball")
                        Text("Team Sports")
                    }
                }
                .buttonStyle(GrowingButtonStyle())
                
                Button (action: {
                })
                {
                    HStack {
                        Image(systemName: "figure.run.treadmill.circle.fill")
                        Text("Cardio")
                    }
                }
                .buttonStyle(GrowingButtonStyle())
            }
        }
    }
}

#Preview {
    RecordWorkoutView()
}
