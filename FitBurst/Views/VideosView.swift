//
//  VideosView.swift
//  FitBurst
//

import SwiftUI
import YouTubePlayerKit
import UIKit

struct Video: Identifiable {
    let id: String  // YouTube video ID
}

struct VideosView: View {
    init() {
        // Customize the Segmented Control appearance
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.limeAccentColor.mix(with:.black, by:0.4))
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(Color.limeAccentColor)
        ], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white
        ], for: .normal)
    }
    
    @State private var selectedSegment = 0
    @State private var appearingItems: Set<Int> = []
    let videoWidth = UIScreen.main.bounds.width-40
    @State private var workoutVideos: [[Video]] = [
        // Weights videos (index 0)
        [
            Video(id: "QsYre__-aro"),
            Video(id: "4Y2ZdHCOXok"),
            Video(id: "3YvfRx31xDE"),
            Video(id: "0A3EgOztptQ")
        ],
        // Running videos (index 1)
        [
            Video(id: "hk4mgq9Ppvk"),
            Video(id: "_kGESn8ArrU"),
            Video(id: "brFHyOtTwH4")
        ],
        // Sport videos (index 2)
        [
            Video(id: "pH_G1f6KzfI"),
            Video(id: "FYJJbwG_i8U"),
            Video(id: "01fRSHG3w5k")
        ],
        // Cardio videos (index 3)
        [
            Video(id: "5O1TTduK6mw"),
            Video(id: "dNJ2gG-Jud4"),
            Video(id: "-hSma-BRzoo")
        ],
        // Yoga videos (index 4) 
        [
            Video(id: "rt1bsoOukjI"),
            Video(id: "yLtV80mATGw"),
            Video(id: "RaPp5jr--xo")
        ],
        // Martial Arts videos (index 5)
        [
            Video(id: "aJS2p5VMk_g"),
            Video(id: "JLSksuDd7Nc"),
            Video(id: "XS2LcpuZcEc")
        ]
    ]
    
    var body: some View {
        ZStack {
            
            BackgroundView()
            
            VStack {
                Text("Videos")
                    .font(.custom("Futura Bold", fixedSize: 40))
                    .foregroundColor(.white)
                
                Picker("Select Category", selection: $selectedSegment) {
                    Image(systemName: WorkoutConfiguration.shared.getIcon(for: 0)).tag(0)
                    Image(systemName: WorkoutConfiguration.shared.getIcon(for: 1)).tag(1)
                    Image(systemName: WorkoutConfiguration.shared.getIcon(for: 2)).tag(2)
                    Image(systemName: WorkoutConfiguration.shared.getIcon(for: 3)).tag(3)
                    Image(systemName: WorkoutConfiguration.shared.getIcon(for: 4)).tag(4)
                    Image(systemName: WorkoutConfiguration.shared.getIcon(for: 5)).tag(5)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .padding(.bottom, -7)
               // .tint(.blue)
                //.accentColor(.blue)
                
                ScrollView {
                    LazyVStack {
                        ForEach(Array(workoutVideos[selectedSegment].enumerated()), id: \.element.id) { index, video in
                            YouTubeVideoView(videoID: video.id)
                                .background(Color.black)
                                .frame(width: videoWidth, height: goldenRatio(videoWidth))
                                .clipShape(RoundedRectangle(cornerRadius: 40))
                                .padding()
                                .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: selectedSegment) { 
                // Reset animations when category changes
                appearingItems.removeAll()
                // Animate new items
                for index in 0..<workoutVideos[selectedSegment].count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                        appearingItems.insert(index)
                    }
                }
            }
            .onAppear {
                // Initial animation
                for index in 0..<workoutVideos[selectedSegment].count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                        appearingItems.insert(index)
                    }
                }
            }
        }
    }
    
    struct YouTubeVideoView: View {
        let videoID: String
        
        @StateObject
        private var youTubePlayer: YouTubePlayer
        
        init(videoID: String) {
            self.videoID = videoID
            _youTubePlayer = StateObject(wrappedValue: YouTubePlayer(
                source: .video(id: videoID)
            ))
        }
        
        var body: some View {
            YouTubePlayerView(self.youTubePlayer) { state in
                switch state {
                case .idle:
                    ProgressView()
                case .ready:
                    EmptyView()
                case .error(_):
                    Text(verbatim: "YouTube player couldn't be loaded")
                }
            }
        }
    }
}

#Preview {
    VideosView()
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
