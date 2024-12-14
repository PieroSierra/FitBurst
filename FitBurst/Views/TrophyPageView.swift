//
//  TrophyView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct TrophyPageView: View {
    var body: some View {
        ZStack {
            Image("GradientWaves").resizable().ignoresSafeArea()
            
            
            VStack {
                Text("Trophies")
                    .font(.custom("Futura Bold", size: 40))
                    .foregroundColor(.white)
                
                TrophyBox(height: 400, scrollHorizontally: false).padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TrophyBox: View {
    var height: CGFloat
    var scrollHorizontally: Bool
    @State private var appearingItems: Set<Int> = []
    @State private var scale: CGFloat = 0.6
    
    private let columns = [GridItem(.adaptive(minimum: 70))]
    private let rows = [GridItem(.adaptive(minimum: 90))]
    
    // Sample data - you can replace this with your actual trophy data later
    private let numberOfTrophies = 17
    
    var body: some View {
           VStack {
                ScrollView(scrollHorizontally ? .horizontal : .vertical) {
                    HStack {
                        Text("Your trophies!").padding(.top, 20).padding(.leading, 20).foregroundStyle(Color.white)
                        Spacer()
                    }.padding(0)
                    if scrollHorizontally {
                        LazyHGrid(rows: rows) {
                            ForEach(0..<numberOfTrophies, id: \.self) { index in
                                SingleTrophyView()
                                    .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
                            }
                        }
                        .padding(20).padding(.top, 0)
                    } else {
                        LazyVGrid(columns: columns) {
                            ForEach(0..<numberOfTrophies, id: \.self) { index in
                                SingleTrophyView()
                                    .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
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

struct SingleTrophyView: View {
    @State private var wasPressed: Bool = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button (action: {
            // insert action here
        }) {
            VStack {
                Image(systemName: "trophy.circle.fill")
                    .resizable()
                    .foregroundStyle(Color.white)
                    .frame(width:75, height:75)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("5 day\nstreak!").font(.caption2).foregroundStyle(Color.white)
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
                    // Schedule wasPressed to be reset after 200ms
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        wasPressed = false
                    }
                }
        )
    }
}

#Preview {
    TrophyPageView()
}
