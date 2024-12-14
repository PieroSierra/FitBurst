//
//  TrophyDisplayView.swift
//  FitBurst
//
//  Created by Piero Sierra on 30/11/2024.
//

import SwiftUI

struct TrophyDisplayView: View {
    @Binding var showTrophyDisplayView: Bool
    @State private var scale: CGFloat = 0.6
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Your trophy:")
                    .foregroundColor(.white)
                Spacer()
                SingleTrophyView()
                    
                .padding(.horizontal)
                
                Spacer()
               
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

#Preview {
    TrophyDisplayView(showTrophyDisplayView: .constant(true))
}
