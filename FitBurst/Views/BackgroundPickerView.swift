//  BackgroundPickerView.swift
//  FitBurst
//
//  Created by Piero Sierra on 02/01/2025.
//

import SwiftUI

struct BackgroundPickerView: View {
    @Binding var showBackgroundPickerView: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.6
    @AppStorage("selectedBackground") private var selectedBackground: String = "Black Tiles"

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Choose your background")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.leading, 4)
                
                ScrollView{
                    Spacer()
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(AppBackgrounds.options, id: \.displayName) { option in
                            Button (action: {
                                selectedBackground = option.displayName
                            })
                            {
                                ZStack {
                                    Image(option.assetName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 90)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .limeAccentColor, radius: 5)
                                    Text(option.displayName)
                                        .foregroundColor(.white)
                                        .padding(10)
                                }.buttonStyle(GrowingButtonStyle())
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(20)
            .frame(width:350, height:670)
            .overlay(dismissButton, alignment: .topTrailing)
            .background(Color.black.opacity(1).clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(color: .limeAccentColor, radius: 10))
            .scaleEffect(scale)
            .onAppear {
                scale = 0.6
                withAnimation(.bouncy) { scale = 1.15 }
                withAnimation(.bouncy.delay(0.25)) { scale = 1 }
            }
        }
        .onTapGesture {
            showBackgroundPickerView = false
        }
    }
    
    private var dismissButton: some View {
        Button(action: {
            showBackgroundPickerView = false
        }) {
            Image(systemName: "xmark.circle")
                .foregroundColor(.gray)
                .font(.title2)
        }
        .padding(25)
    }
    
}

#Preview {
    BackgroundPickerView(showBackgroundPickerView: .constant(true))
}