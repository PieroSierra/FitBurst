//
//  ContentView.swift
//  FitBurst
//
//  Created by Nikola Sierra on 24/11/2024.
//

import SwiftUI
import CoreData

enum Tab: String, CaseIterable {
    case home = "Home"
    case calendar = "Calendar"
    case videos = "Videos"
    case trophies = "Trophies"
    case settings = "Settings"
}
 
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedTab: Tab = .home
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        appearance.backgroundEffect = blurEffect
        
        appearance.backgroundColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = nil
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.white.opacity(0.5))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.white.opacity(0.5))]
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(Tab.home)
            CalendarView()
                .tag(Tab.calendar)
                .tabItem { Label("Calendar", systemImage: "calendar") }
            VideosView()
                .tag(Tab.videos)
                .tabItem { Label("Videos", systemImage: "play.rectangle.fill") }
            TrophyPageView()
                .tag(Tab.trophies)
                .tabItem { Label("Trophies", systemImage: "trophy.fill") }
            SettingsView()
                .tag(Tab.settings)
                .tabItem { Label("Settings", systemImage: "person.circle.fill") }
        }
        .tint(.limeAccentColor)
    }
}

extension Notification.Name {
    static let scrollToTop = Notification.Name("scrollToTop")
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
