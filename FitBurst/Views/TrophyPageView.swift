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
    
    private let columns = [GridItem(.adaptive(minimum: 90))]
    private let rows = [GridItem(.adaptive(minimum: 90))]
    
    var body: some View {
        VStack {
            ScrollView(scrollHorizontally ? .horizontal : .vertical) {
                if scrollHorizontally {
                    LazyHGrid(rows: rows) {
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                    }
                    .padding()
                } else {
                    LazyVGrid(columns: columns) {
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                        SingleTrophyView()
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        Spacer()
    }
    
    struct SingleTrophyView: View {
        var body: some View {
            VStack {
                Image("LogoSq")
                    .resizable()
                    .frame(width:75, height:75)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("5 day streak!")
            }
        }
    }
}


#Preview {
    TrophyPageView()
}
