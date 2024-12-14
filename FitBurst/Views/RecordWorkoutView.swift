//
//  RecordWorkoutView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 30/11/2024.
//

import SwiftUI

struct RecordWorkoutView: View {
    @Binding var showWorkoutView: Bool
    @Binding var selectedDate: Date
    @State private var scale: CGFloat = 0.6

    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack {
                Spacer()

                HStack {
                    Text("Worked out:")
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
                
                Spacer()
                HStack {
                    Button (action: {  })
                    {
                        HStack {
                            Image(systemName: "dumbbell.fill").imageScale(.large)
                            Text("Strength")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Button (action: {  })
                    {
                        HStack {
                            Image(systemName: "figure.run.circle.fill").imageScale(.large)
                            Text("Run")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                }
                HStack {
                    Button (action: {  })
                    {
                        HStack {
                            Image(systemName: "soccerball").imageScale(.large)
                            Text("Team Sport")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Button (action: {  })
                    {
                        HStack {
                            Image(systemName: "figure.run.treadmill.circle.fill").imageScale(.large)
                            Text("Cardio")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                }
                HStack {
                    Button (action: {  })
                    {
                        HStack {
                            Image(systemName: "figure.yoga.circle.fill").imageScale(.large)
                            Text("Yoga")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Button (action: {  })
                    {
                        HStack {
                            Image(systemName: "figure.martial.arts.circle.fill").imageScale(.large)
                            Text("Martial Arts")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                }
            }
            .frame(width:350,height:250)
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
