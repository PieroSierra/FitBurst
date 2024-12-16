//
//  TrophyView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI
import Model3DView


struct TrophyPageView: View {
    @State private var showTrophyDisplayView: Bool = false
    @State private var selectedTrophy: TrophyType = .gold
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            VStack {
                Text("Trophies")
                    .font(.custom("Futura Bold", size: 40))
                    .foregroundColor(.white)
                
                TrophyBox(
                    height: 400,
                    scrollHorizontally: false,
                    showTrophyDisplayView: $showTrophyDisplayView,
                    selectedTrophy: $selectedTrophy
                )
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showTrophyDisplayView {
                SingleTrophyView(
                    showTrophyDisplayView: $showTrophyDisplayView,
                    trophyType: selectedTrophy
                )
            }
        }
    }
}

struct TrophyBox: View {
    var height: CGFloat
    var scrollHorizontally: Bool
    @State private var appearingItems: Set<Int> = []
    @State private var scale: CGFloat = 0.6
    @Binding var showTrophyDisplayView: Bool
    @Binding var selectedTrophy: TrophyType
    
    @State var trophies: [TrophyType] = {
        var types: [TrophyType] = []
        for _ in 0..<17 {
            types.append(TrophyType.allCases.randomElement()!)
        }
        return types
    }()
    
    let columns = [GridItem(.adaptive(minimum: 70))]
    let rows = [GridItem(.adaptive(minimum: 90))]
    let numberOfTrophies = 17
    
    private func trophyIcon(for trophy: TrophyType, at index: Int) -> some View {
        TrophyIconView(
            showTrophyDisplayView: $showTrophyDisplayView,
            selectedTrophy: $selectedTrophy,
            trophyType: trophy
        )
        .scaleEffect(appearingItems.contains(index) ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
    }
    
    var body: some View {
        VStack {
            ScrollView(scrollHorizontally ? .horizontal : .vertical) {
                if scrollHorizontally {
                    LazyHGrid(rows: rows) {
                        ForEach(Array(trophies.enumerated()), id: \.offset) { index, trophy in
                            trophyIcon(for: trophy, at: index)
                        }
                    }
                    .padding(20).padding(.top, 0)
                } else {
                    LazyVGrid(columns: columns) {
                        ForEach(Array(trophies.enumerated()), id: \.offset) { index, trophy in
                            trophyIcon(for: trophy, at: index)
                        }
                    }
                    .padding(20).padding(.top, 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .scaleEffect(scale)
        .onAppear {
            if trophies.isEmpty {
                trophies = (0..<numberOfTrophies).map { _ in
                    TrophyType.allCases.randomElement()!
                }
            }
            // Animat the box itself
            scale = 0.6
            withAnimation(.bouncy) { scale = 1.15 }
            withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            
            // Animate items appearing one by one
            // appearingItems = []
            for index in 0..<numberOfTrophies {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    appearingItems.insert(index)
                }
            }
            
        }
        Spacer()
    }
    
}


#Preview {
    TrophyPageView()
}
