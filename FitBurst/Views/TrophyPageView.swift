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
    @State private var selectedTrophy: TrophyType = .newbie
    
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Trophies")
                    .font(.custom("Futura Bold", size: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                ScrollView {
                    TrophyBox(
                        scrollHorizontally: false,
                        showTrophyDisplayView: $showTrophyDisplayView,
                        selectedTrophy: $selectedTrophy
                    )
                }
            }
            
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
    var scrollHorizontally: Bool
    @State private var appearingItems: Set<Int> = []
    @State private var scale: CGFloat = 0.6
    @Binding var showTrophyDisplayView: Bool
    @Binding var selectedTrophy: TrophyType
    
    @State var trophies: [TrophyType] = {
        var types: [TrophyType] = []
        for _ in 0..<24 {
            types.append(TrophyType.allCases.randomElement()!)
        }
        return types
    }()
    
    let columns = [GridItem(.adaptive(minimum: 70))]
    let rows = [GridItem(.adaptive(minimum: 90))]
    let numberOfTrophies = 24
    
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
        Group {
            if scrollHorizontally {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows) {
                        ForEach(Array(trophies.enumerated()), id: \.offset) { index, trophy in
                            trophyIcon(for: trophy, at: index)
                                .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                .animation(
                                    .spring(response: 0.25, dampingFraction: 0.6)
                                    .delay(Double(index) * 0.05),
                                    value: appearingItems.contains(index)
                                )
                        }
                    }
                    .padding(20)
                    .padding(.top, 0)
                }
                .scaleEffect(scale)
            } else {
                // For vertical, just the grid without ScrollView
                LazyVGrid(columns: columns) {
                    ForEach(Array(trophies.enumerated()), id: \.offset) { index, trophy in
                        trophyIcon(for: trophy, at: index)
                            .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                            .animation(
                                .spring(response: 0.25, dampingFraction: 0.6)
                                .delay(Double(index) * 0.05),
                                value: appearingItems.contains(index)
                            )
                    }
                }
                .padding(20)
                .padding(.top, 0)
                .scaleEffect(scale)
            }
        }
        .onAppear {
            // Animate the box itself (also faster)
            scale = 0.6
            withAnimation(.bouncy.speed(2)) { scale = 1.15 }
            withAnimation(.bouncy.speed(2).delay(0.125)) { scale = 1 }
            
            // Reset appearing items
            appearingItems.removeAll()
            
            // Animate items appearing one by one
            for index in 0..<numberOfTrophies {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    appearingItems.insert(index)
                }
            }
        }
    }
    
}


#Preview {
    TrophyPageView()
}
