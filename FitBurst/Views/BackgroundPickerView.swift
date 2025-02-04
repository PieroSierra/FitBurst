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
    @Bindable private var appState = AppState.shared

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
                
                ScrollView {
                    Spacer().frame(minHeight: 20)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(appState.backgroundOptions, id: \.assetName) { option in
                            Button(action: {
                                appState.currentBackground = option.assetName
                                showBackgroundPickerView = false
                            }) {
                                ZStack {
                                    Image(option.assetName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width/4.5)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .limeAccentColor, radius: 5)
                                    Text(option.displayName)
                                        .foregroundColor(.white)
                                        .padding(10)
                                }
                                .buttonStyle(GrowingButtonStyle())
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(20)
            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 200)
            .overlay(dismissButton, alignment: .topTrailing)
            .overlay(
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors:[Color.black.opacity(0.0), Color.black.opacity(1.0)]),
                        startPoint: .bottom,
                        endPoint: .top
                    ))
                    .frame(width: UIScreen.main.bounds.width-70, height: 20).padding(.top,69)
                , alignment:.top)
            .overlay(
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.0),  Color.black.opacity(1.0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: UIScreen.main.bounds.width-70, height: 20).padding(.bottom,20)
                , alignment:.bottom)
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
