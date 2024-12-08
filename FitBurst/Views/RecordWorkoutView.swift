//
//  RecordWorkoutView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 30/11/2024.
//

import SwiftUI

struct RecordWorkoutView: View {
    @Binding var showWorkoutView: Bool
    @State private var scale: CGFloat = 0.6
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Record your workout")
                Spacer()
                HStack {
                    Button (action: {
                    })
                    {
                        HStack {
                            Image(systemName: "dumbbell.fill").imageScale(.large)
                            Text("Weights")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Button (action: {
                    })
                    {
                        HStack {
                            Image(systemName: "figure.run.circle.fill").imageScale(.large)
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
                            Image(systemName: "soccerball").imageScale(.large)
                            Text("Team Sport")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Button (action: {
                    })
                    {
                        HStack {
                            Image(systemName: "figure.run.treadmill.circle.fill").imageScale(.large)
                            Text("Cardio")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                }
                HStack {
                    Button (action: {
                    })
                    {
                        HStack {
                            Image(systemName: "figure.yoga.circle.fill").imageScale(.large)
                            Text("Yoga")
                        }
                    }
                    .buttonStyle(GrowingButtonStyle())
                    
                    Button (action: {
                    })
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
            .background(Color.greenBrandColor.clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(radius: 10))
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
    RecordWorkoutView(showWorkoutView: .constant(true))
}
