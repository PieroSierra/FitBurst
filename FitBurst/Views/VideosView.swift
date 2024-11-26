//
//  VideosView.swift
//  FitBurst
//
//  Created by Olga Uskova-Sierra on 24/11/2024.
//

import SwiftUI

struct VideosView: View {
    @State private var selectedSegment = 0
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "video")
                    .imageScale(.large)
                Text("Videos")
                    .font(.title)
            }
            Picker("Select Category", selection: $selectedSegment) {
                Text("🏋🏿‍♀️ Weights").tag(0)
                Text("🏃🏽‍♂️ Running").tag(1)
                Text("🧘🏻‍♂️ Yoga").tag(2)
                Text("⚽️ Sport").tag(3)
                    .bold()
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.bottom, -7)
            
            
            if (selectedSegment == 0) {
                ScrollView() {
                    VideoView(videoID: "QsYre__-aro")
                  //      .scaledToFill()
                        .frame(width: 320, height: 198) // Golden Ratio
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding()
                    VideoView(videoID: "4Y2ZdHCOXok")
                       // .scaledToFill()
                        .frame(width: 320, height: 198) // Golden Ratio
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding()
                    VideoView(videoID: "3YvfRx31xDE")
               //         .scaledToFill()
                        .frame(width: 320, height: 198) // Golden Ratio
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding()
                    VideoView(videoID: "0A3EgOztptQ")
               //         .scaledToFill()
                        .frame(width: 320, height: 198) // Golden Ratio
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding()
                    Spacer()
                }
                
            }
            else if (selectedSegment == 1) {
                ScrollView() {
                    VideoView(videoID: "_kGESn8ArrU")
                     //   .scaledToFill()
                        .frame(width: 320, height: 198) // Golden Ratio
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .padding()
                    Spacer()
                }
            }
            else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.greenBrandColor)
    }
}

#Preview {
    VideosView()
}
