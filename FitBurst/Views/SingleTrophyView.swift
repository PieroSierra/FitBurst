//
//  TrophyDisplayView.swift
//  FitBurst
//
//  Created by Piero Sierra on 30/11/2024.
//

import SwiftUI
import Model3DView

enum TrophyType: CaseIterable {
    case newbie
    case fiveX
    case tenX
    case twentyFiveX
    case fiftyX
    case oneHundredX
    case twoHundredX
    case firstPerfectWeek
    case secondPerfectWeek
    case thirdPerfectWeek
    case fourthPerfectWeek
    case fifthPerfectWeek
    case sixthPerfectWeek
    case seventhPerfectWeek
    case twoInADay
    case threeInADay
    case lotsInADay
    
    var displayName: String {
        switch self {
        case .newbie: return "First workout!"
        case .fiveX: return "5 in a row"
        case .tenX: return "10 in a row!"
        case .twentyFiveX: return "25 in a row!"
        case .fiftyX: return "50 in a row!!"
        case .oneHundredX: return "100 in a row!!"
        case .twoHundredX: return "200 in a row!!!"
        case .firstPerfectWeek: return "First Perfect Week"
        case .secondPerfectWeek: return "Second Perfect Week"
        case .thirdPerfectWeek: return "Third Perfect Week!"
        case .fourthPerfectWeek: return "Fourth Perfect Week!"
        case .fifthPerfectWeek: return "Fifth Perfect Week!!"
        case .sixthPerfectWeek: return "Sixth Perfect Week!!"
        case .seventhPerfectWeek: return "Seventh Perfect Week!!!"
        case .twoInADay: return "Two in a day"
        case .threeInADay: return "Three in a day"
        case .lotsInADay: return "Lots in a day"
        }
    }
    
    var fileName: String {
        switch self {
        case .newbie: return "Coin_Star_Silver.usdz"
        case .fiveX: return "Coin_Zap_Silver.usdz"
        case .tenX: return "Coin_Zap_Gold.usdz"
        case .twentyFiveX: return "Coin_Crown_Gold.usdz"
        case .fiftyX: return "Star_Cup.usdz"
        case .oneHundredX: return "1_Stack_Coins.usdz"
        case .twoHundredX: return "3_Stacks_Coins.usdz"
        case .firstPerfectWeek: return "Gem_01_Red.usdz"
        case .secondPerfectWeek: return "Gem_02_Red.usdz"
        case .thirdPerfectWeek: return "Diamond_Red.usdz"
        case .fourthPerfectWeek: return "Gem_01_Green.usdz"
        case .fifthPerfectWeek: return "Gem_02_Green.usdz"
        case .sixthPerfectWeek: return "Diamond_Green.usdz"
        case .seventhPerfectWeek: return "Diamond_Blue.usdz"
        case .twoInADay: return "2_Coins_Silver.usdz"
        case .threeInADay: return "3_Coins_Gold.usdz"
        case .lotsInADay: return "5_Coins_Gold.usdz"
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
                
                Text("\(trophyType.displayName)")
                    .padding(.top, 10)
                    .foregroundColor(.white)
                    .font(.custom("Futura Bold", size: 20))
                
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
                    modelScale = SIMD3<Float>(repeating: 1)
                }
                
                withAnimation(.spring(
                    response: 2.0,
                    dampingFraction: 0.7,
                    blendDuration: 1.0
                )) {
                    rotationDegrees = 360+180
                }
                rippleCounter += 1
               // playSound(named: "Cinematic Riser Sound Effect")
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
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            showTrophyDisplayView = false
                        }
                )
                
            VStack{
                Rectangle()
                    .fill(Color.clear)
                    .ignoresSafeArea()
                    .frame(width: .infinity, height: 200)
                    .onTapGesture {
                        showTrophyDisplayView = false
                    }
                Spacer()
                Rectangle()
                    .fill(Color.clear)
                    .ignoresSafeArea()
                    .frame(width: .infinity, height: 160)
                    .onTapGesture {
                        showTrophyDisplayView = false
                    }
            }

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
                ZStack{
                    Circle().frame(width:70, height:70).foregroundColor(Color.limeAccentColor.opacity(0.25))
                    Model3DView(named: trophyType.fileName)
                        .frame(width:70, height:70)
                }
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
    SingleTrophyView(showTrophyDisplayView: .constant(true), trophyType: .threeInADay)
}
