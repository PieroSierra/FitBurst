//
//  TrophyView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct TrophyPageView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "medal")
                    .imageScale(.large)
                
                Text("Trophies")
                    .font(.title)
                    .bold()
            }
            
            TrophyBox(height: 400, scrollHorizontally: false).padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}

struct TrophyBox: View {
    var height: CGFloat
    var scrollHorizontally: Bool
    @State private var appearingItems: Set<Int> = []
    
    private let columns = [GridItem(.adaptive(minimum: 70))]
    private let rows = [GridItem(.adaptive(minimum: 90))]
    
    // Sample data - you can replace this with your actual trophy data later
    private let numberOfTrophies = 17
    
    var body: some View {
        VStack {
            ScrollView(scrollHorizontally ? .horizontal : .vertical) {
                if scrollHorizontally {
                    LazyHGrid(rows: rows) {
                        ForEach(0..<numberOfTrophies, id: \.self) { index in
                            SingleTrophyView()
                                .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
                        }
                    }
                    .padding(20)
                } else {
                    LazyVGrid(columns: columns) {
                        ForEach(0..<numberOfTrophies, id: \.self) { index in
                            SingleTrophyView()
                                .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
                        }
                    }
                    .padding(20)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .onAppear {
            // Animate items appearing one by one
            for index in 0..<numberOfTrophies {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    appearingItems.insert(index)
                }
            }
        }
        Spacer()
    }
    
    struct SingleTrophyView: View {
        var body: some View {
            VStack {
                Image("LogoSq")
                    .resizable()
                    .frame(width:75, height:75)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("5 day\nstreak!").font(.caption2)
            }
        }
    }
}


#Preview {
    TrophyPageView()
}
