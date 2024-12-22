//
//  MascotView.swift
//  FitBurst
//
//  Created by Piero Sierra on 30/11/2024.
//

import SwiftUI

struct MascotView: View {
    @State private var isBlinking = false
    @State private var blinkTimer: Timer?
    
    var body: some View {
        Image(isBlinking ? "LogoSqClearEyesClosed" : "LogoSqClear")
            .resizable()
            .frame(width: 200, height: 200)
            .onAppear {
                startBlinking()
            }
            .onDisappear {
                blinkTimer?.invalidate()
            }
    }
    
    private func startBlinking() {
        // Schedule the next blink
        func scheduleNextBlink() {
            let randomInterval = Double.random(in: 1...3)
            blinkTimer = Timer.scheduledTimer(withTimeInterval: randomInterval, repeats: false) { _ in
                // Start the blink
                isBlinking = true
                
                // End the blink after 0.15 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isBlinking = false
                    scheduleNextBlink() // Schedule the next blink
                }
            }
        }
        
        scheduleNextBlink() // Start the blinking cycle
    }
}

struct MascotView_Previews: PreviewProvider {
    static var previews: some View {
        MascotView()
    }
}
