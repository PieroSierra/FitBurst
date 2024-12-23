//
//  RecordWorkoutView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 30/11/2024.
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


enum SoundScape: String {
    // Sci Fi 1
    //case buildup = "Sci-Fi Sound Effect Designed Circuits SFX 32"
    //case release = "Sci-Fi Sound Effect Circuits SFX 31"
    
   
    
    // Cinematic + Futuristic
    // case buildup = "Cinematic Riser Sound Effect (1)"
    // case release = "Futuristic Whoosh Sound Effect"
    
    // Cinematic + TikTok
    //case buildup = "Cinematic Riser Sound Effect (1)"
    //case release = "TikTok Boom Bling Sound Effect"
    
    // Cinematic2 + TikTok
    case buildup = "Cinematic Riser Sound Effect"
    case release = "TikTok Boom Bling Sound Effect"
    

}


struct RecordWorkoutView: View {
    @Binding var showWorkoutView: Bool
    @Binding var selectedDate: Date
    @State private var scale: CGFloat = 0.6
    
    ///for ripple
    @State private var rippleCounter: Int = 0
    @State private var ripplePosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    
    func triggerRipple(at position: CGPoint) {
        let adjustedPosition = CGPoint(
            x: position.x,
            y: position.y - 65  // Subtract the VStack offset
        )
        ripplePosition = adjustedPosition
        rippleCounter += 1
    }
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .modifier(RippleEffect(at: ripplePosition, trigger: rippleCounter, amplitude: -22, frequency: 15, decay: 4, speed: 600))
            
 
            VStack {
                Spacer().frame(height: 50)

                Text("**Press & hold** to record workout:")
                    .foregroundColor(.white)
                    .onTapGesture {
                        rippleCounter += 1
                    }

                Spacer().frame(height: 30)

                HStack {
                    Group {
                        Button (action: {
                            let workoutType: Int32 = 0  // Replace with the corresponding workout type
                            PersistenceController.shared.recordWorkout(date: selectedDate, workoutType: workoutType)
                        })
                        {
                            HStack {
                                Image(systemName: "dumbbell.fill").imageScale(.large)
                                Text("Strength")
                            }
                        }
                        
                        Button (action: {
                            let workoutType: Int32 = 1  // Replace with the corresponding workout type
                            PersistenceController.shared.recordWorkout(date: selectedDate, workoutType: workoutType)
                        })
                        {
                            HStack {
                                Image(systemName: "figure.run.circle.fill").imageScale(.large)
                                Text("Run")
                            }
                        }
                    }
                    .padding(5)
                    .buttonStyle(FillUpButtonStyle(onComplete: triggerRipple))
                }
                HStack {
                    Group {
                        Button (action: {
                            let workoutType: Int32 = 2  // Replace with the corresponding workout type
                            PersistenceController.shared.recordWorkout(date: selectedDate, workoutType: workoutType)
                        })
                        {
                            HStack {
                                Image(systemName: "soccerball").imageScale(.large)
                                Text("Team Sport")
                            }
                        }
                        
                        Button (action: {
                            let workoutType: Int32 = 3  // Replace with the corresponding workout type
                            PersistenceController.shared.recordWorkout(date: selectedDate, workoutType: workoutType)
                        })
                        {
                            HStack {
                                Image(systemName: "figure.run.treadmill.circle.fill").imageScale(.large)
                                Text("Cardio")
                            }
                        }
                    }
                    .padding(5)
                    .buttonStyle(FillUpButtonStyle(onComplete: triggerRipple))
                    
                }
                HStack {
                    Group {
                        Button (action: {
                            let workoutType: Int32 = 4  // Replace with the corresponding workout type
                            PersistenceController.shared.recordWorkout(date: selectedDate, workoutType: workoutType)
                        })
                        {
                            HStack {
                                Image(systemName: "figure.yoga.circle.fill").imageScale(.large)
                                Text("Yoga")
                            }
                        }

                        Button (action: {
                            let workoutType: Int32 = 5  // Replace with the corresponding workout type
                            PersistenceController.shared.recordWorkout(date: selectedDate, workoutType: workoutType)
                        })
                        {
                            HStack {
                                Image(systemName: "figure.martial.arts.circle.fill").imageScale(.large)
                                Text("Martial Arts")
                            }
                        }
                    }
                    .padding(5)
                    .buttonStyle(FillUpButtonStyle(onComplete: triggerRipple))

                }
                
                Spacer().frame(height: 60)
                
            }
            .frame(width:350,height:330)
            .padding(.bottom, 40)
            .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(color: .limeAccentColor, radius: 10))
            .overlay(dismissButton, alignment: .topTrailing)
            .scaleEffect(scale)
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
            .modifier(RippleEffect(
                at: CGPoint(
                    x: ripplePosition.x - (UIScreen.main.bounds.width - 350)/2,  // Center X in VStack
                    y: ripplePosition.y - (UIScreen.main.bounds.height - 330)/2+65  // Center Y in VStack
                ),
                trigger: rippleCounter,
                amplitude: -12,
                frequency: 15,
                decay: 8,
                speed: 650
            ))
            /* /// Debug circle to visualize the ripple position
           Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(ripplePosition) */
            
            HStack {
                Text("Workout date:")
                    .foregroundColor(.white)
                
                DatePicker("",
                           selection: $selectedDate,
                           displayedComponents: [.date])
                .labelsHidden()
                .accentColor(.limeAccentColor)
                .colorScheme(.dark)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .scaleEffect(scale)
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
            .offset(y: +150)
            
        }
        .onTapGesture {
            showWorkoutView = false
        }

    }
    
    private var dismissButton: some View {
        Button(action: {
            showWorkoutView = false
        }) {
            Image(systemName: "xmark.circle")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .padding()
    }
}

#Preview {
    RecordWorkoutView(showWorkoutView: .constant(true), selectedDate: .constant(Date()))
}
