//
//  VideosView.swift
//  FitBurst
//

import SwiftUI
import YouTubePlayerKit
import UIKit

struct Video: Identifiable {
    let id: String  // This will be your YouTube video ID
    // Add other properties as needed
}

struct VideosView: View {
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
            Video(id: "_kGESn8ArrU"),
            Video(id: "brFHyOtTwH4")
        ],
        // Yoga videos (index 2)
        [],
        // Sport videos (index 3)
        []
    ]
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "video")
                    .imageScale(.large)
                
                Text("Videos")
                    .font(.title)
                    .bold()
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
            
            ScrollView {
                LazyVStack {
                    ForEach(Array(workoutVideos[selectedSegment].enumerated()), id: \.element.id) { index, video in
                        YouTubeVideoView(videoID: video.id)
                            .background(Color.darkGreenBrandColor)
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
        .background(Color.greenBrandColor)
        .onChange(of: selectedSegment) { _ in
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
}
