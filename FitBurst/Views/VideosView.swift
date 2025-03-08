//
//  VideosView.swift
//  FitBurst
//

import SwiftUI
import YouTubePlayerKit
import UIKit
import Combine

// Models for YouTube API Response
struct YouTubeSearchResponse: Codable {
    let kind: String?
    let etag: String?
    let items: [YouTubeSearchItem]
    let pageInfo: PageInfo?
    
    // Add CodingKeys to make only items required
    private enum CodingKeys: String, CodingKey {
        case kind, etag, items, pageInfo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        etag = try container.decodeIfPresent(String.self, forKey: .etag)
        items = try container.decode([YouTubeSearchItem].self, forKey: .items)
        pageInfo = try container.decodeIfPresent(PageInfo.self, forKey: .pageInfo)
    }
}

struct PageInfo: Codable {
    let totalResults: Int?
    let resultsPerPage: Int?
}

struct YouTubeSearchItem: Codable {
    let kind: String?
    let etag: String?
    let id: VideoID
    let snippet: Snippet
}

struct VideoID: Codable {
    let kind: String?
    let videoId: String
}

struct Snippet: Codable {
    let publishedAt: String?
    let channelId: String?
    let title: String
    let description: String?
    let thumbnails: [String: Thumbnail]?
    let channelTitle: String?
    let liveBroadcastContent: String?
    let publishTime: String?
}

struct Thumbnail: Codable {
    let url: String
    let width: Int?
    let height: Int?
}

// Example Video Struct
struct Video: Identifiable {
    let id: String
    let title: String
}

struct VideosView: View {
    private let baseUrl = "https://www.googleapis.com/youtube/v3/search"
    private let apiKey = Secrets.youtubeApiKey
    private var appState = AppState.shared
    private let isPreview: Bool
    
    init(isPreview: Bool = false) {
        self.isPreview = isPreview
        self._workoutVideos = State(initialValue: Array(repeating: [], count: 6))
        
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
    @State private var workoutVideos: [[Video]] = []
    @State private var cancellables = Set<AnyCancellable>()
    @State private var hasLoadedVideos = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var videosReady = false
    
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                Text("Videos")
                    .font(.custom("Futura Bold", fixedSize: 40))
                    .foregroundColor(.white)
                
                // Only show picker segments for visible workout types
                Picker("Select Category", selection: $selectedSegment) {
                    ForEach(0..<6) { index in
                        if WorkoutConfiguration.shared.isVisible(for: Int32(index)) {
                            if (WorkoutConfiguration.shared.countWorkouts() < 4) {
                                Text(WorkoutConfiguration.shared.getName(for: Int32(index)))
                                    .tag(index)
                            }
                            else {
                                Image(systemName: WorkoutConfiguration.shared.getIcon(for: Int32(index)))
                                    .tag(index)
                            }
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack {
                        if selectedSegment < workoutVideos.count && videosReady {
                            ForEach(Array(workoutVideos[selectedSegment].enumerated()), id: \.element.id) { index, video in
                                VStack {
                                    YouTubeVideoView(videoID: video.id)
                                        .background(Color.black)
                                        .frame(width: videoWidth, height: goldenRatio(videoWidth))
                                        .clipShape(RoundedRectangle(cornerRadius: 40))
                                        .padding()
                                        .scaleEffect(appearingItems.contains(index) ? 1 : 0)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appearingItems.contains(index))
                                }
                            }
                        } else {
                            // error case
                        }
                    }
                }
            }
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
                if !hasLoadedVideos {
                    fetchWorkoutVideos()
                }
            }
            
            if (showError) {
                Group {
                    VStack {
                        Text("Error loading videos")
                            .font(.title2)
                        Text(errorMessage)
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
            
            // Loading spinner overlay
            if !videosReady && !showError {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                    
                    Text("Loading videos...")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
            }
            
            /*/ Add error alert
             .alert("Error Loading Videos", isPresented: $showError) {
             Button("OK", role: .cancel) { }
             } message: {
             Text(errorMessage)
             }*/
        }
    }
    
    func fetchWorkoutVideos() {
        // Only fetch videos for visible workout types
        let visibleTypes = (0..<6).filter { 
            WorkoutConfiguration.shared.isVisible(for: Int32($0)) 
        }
        
        workoutVideos = Array(repeating: [], count: 6)  // Keep array size consistent
        
        for type in visibleTypes {
            let name = WorkoutConfiguration.shared.getName(for: Int32(type))
            
            let query = "\(name) workout technique".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "\(baseUrl)?q=\(query)&type=video&videoDuration=short&videoDefinition=standard&safeSearch=strict&relevanceLanguage=en&order=rating&part=snippet&maxResults=4&key=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL for type \(type)")
                continue
            }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .handleEvents(receiveOutput: { data in
                    // Print first item for debugging
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let items = json["items"] as? [[String: Any]],
                       let firstItem = items.first {
                        // print("📺 Sample video item: \(firstItem)")
                    }
                })
                .decode(type: YouTubeSearchResponse.self, decoder: JSONDecoder())
                .map { response in
                     return response.items.map { item in
                        let videoId = item.id.videoId
                        //print("📺 Video ID: \(videoId), Title: \(item.snippet.title)")
                        return Video(id: videoId, title: item.snippet.title)
                    }
                }
                .catch { error -> Just<[Video]> in
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                    return Just([])
                }
                .receive(on: DispatchQueue.main)
                .sink { videos in
                    if type < self.workoutVideos.count {
                        self.workoutVideos[type] = videos
                        
                        // Check if all video types are loaded
                        let totalVideos = self.workoutVideos.reduce(0) { $0 + $1.count }
                        if totalVideos == visibleTypes.count * 4 { // Expecting 4 videos per type
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.videosReady = true
                                // Initialize animation for initial videos
                                for index in 0..<self.workoutVideos[self.selectedSegment].count {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                                        self.appearingItems.insert(index)
                                    }
                                }
                            }
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    struct YouTubeVideoView: View {
        let videoID: String
        
        var body: some View {
            YouTubePlayerView(YouTubePlayer(
                source: .video(id: videoID),
                configuration: .init(
                    autoPlay: false,
                    showControls: true
                )
            )) { state in
                switch state {
                case .idle:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                case .ready:
                    EmptyView()
                case .error(let error):
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
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
