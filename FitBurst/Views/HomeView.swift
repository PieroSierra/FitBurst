//
//  HomeView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("FitBurst")
                .font(.system(size: 28))
                .bold()
            Image("LogoSq")
                .resizable()
                .frame(width:200, height:200)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button (action: {
                // insert action here
            }) {
                HStack {
                    Image(systemName: "dumbbell")
                    Text("Record Workout")
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .background(Color.white.opacity(0.6))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}

#Preview {
    HomeView()
}
