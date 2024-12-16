//
//  TrophyDisplayView.swift
//  FitBurst
//
//  Created by Piero Sierra on 30/11/2024.
//

import SwiftUI
import Model3DView

enum TrophyType: CaseIterable {
    case gold
    case silver
    case bronze
    case team_sport
    
    var displayName: String {
        switch self {
        case .gold:
            return "Gold\nAward"
        case .silver:
            return "Silver\nAward"
        case .bronze:
            return "Bronze\nAward"
        case .team_sport:
            return "Team\nAward"
        }
    }
    
    var fileName: String {
        switch self {
        case .gold:
            return "Gold Trophy 3D Model.usdz"
        case .silver:
            return "Sliver Trophy 3D Model.usdz"
        case .bronze:
            return "Bronze Trophy 3D Model.usdz"
        case .team_sport:
            return "Golden Ball Award 3D Model.usdz"
        }
    }
}

struct SingleTrophyView: View {
    @Binding var showTrophyDisplayView: Bool
    let trophyType: TrophyType 
    @State private var scale: CGFloat = 0.6
    @State private var modelScale: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @State private var rotationDegrees: CGFloat = 0
    
    /// 3d Camera
    @State var camera = PerspectiveCamera(fov: .degrees(90))
    
    /// For Ripple
    @State private var rippleCounter: Int = 0
//    @State private var ripplePosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    @State private var ripplePosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .modifier(RippleEffect(at: ripplePosition, trigger: rippleCounter, amplitude: -22, frequency: 15, decay: 4, speed: 600))
            
            VStack {
                Spacer()
                
                Text("Your trophy:")
                    .foregroundColor(.white)
                Spacer()

                .padding(.horizontal)
                
                Spacer()
            }
            .frame(width:350,height:450)
            .background(Color.black.opacity(0.9).clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(color: .limeAccentColor, radius: 10))
            .overlay(dismissButton, alignment: .topTrailing)
            .scaleEffect(scale)
            .modifier(RippleEffect(at:
                                    CGPoint(
                                        x: ripplePosition.x - (UIScreen.main.bounds.width - 350)/2,  // Center X in VStack
                                        y: ripplePosition.y - (UIScreen.main.bounds.height - 350)/2  // Center Y in VStack
                                    ),trigger: rippleCounter, amplitude: -22, frequency: 15, decay: 4, speed: 300))
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
                
                withAnimation(.spring(
                    response: 1.0,
                    dampingFraction: 0.6,
                    blendDuration: 0.5
                )) {
                    modelScale = SIMD3<Float>(repeating: 1.0)
                }
                
                withAnimation(.spring(
                    response: 2.0,
                    dampingFraction: 0.7,
                    blendDuration: 1.0
                )) {
                    rotationDegrees = 360
                }
                rippleCounter += 1
            }
            
            Model3DView(named: trophyType.fileName)  // Use the passed trophy type
                .transform(
                    rotate: Euler(y: .degrees(rotationDegrees)),
                    scale: modelScale,
                    translate: [0, 0, 0]
                )
                .cameraControls(OrbitControls(
                    camera: $camera,
                    sensitivity: 0.5
                ))
                .frame(width: 350, height: 370)

        }
        .onTapGesture {
            showTrophyDisplayView = false
        }
    }
    
    private var dismissButton: some View {
        Button(action: {
            showTrophyDisplayView = false
        }) {
            Image(systemName: "xmark.circle")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .padding()
    }
}


struct TrophyIconView: View {
    @State private var wasPressed: Bool = false
    @State private var scale: CGFloat = 1.0
    @Binding var showTrophyDisplayView: Bool
    @Binding var selectedTrophy: TrophyType
    let trophyType: TrophyType
    
    var body: some View {
        Button (action: {
            selectedTrophy = trophyType
            showTrophyDisplayView = true
        }) {
            VStack {
                Model3DView(named: trophyType.fileName)
                    .frame(width:70, height:70)
                Text(trophyType.displayName)
                    .font(.caption2)
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
            }
        }
        .foregroundStyle(.blue)
        .scaleEffect(wasPressed ? 0.9 : scale)
        .animation(.spring(response: 0.2), value: wasPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    wasPressed = true
                }
                .onEnded { _ in
                    wasPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        wasPressed = false
                    }
                }
        )
    }
}


#Preview {
    SingleTrophyView(showTrophyDisplayView: .constant(true), trophyType: .gold)
}
