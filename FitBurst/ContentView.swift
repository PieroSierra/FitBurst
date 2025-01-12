//
//  ContentView.swift
//  FitBurst
//
//  Created by Nikola Sierra on 24/11/2024.
//

import SwiftUI
import CoreData
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

enum Tab: String, CaseIterable {
    case home = "Home"
    case calendar = "Calendar"
    case videos = "Videos"
    case trophies = "Trophies"
    case settings = "Settings"
}
 
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("firstRunComplete") private var firstRunComplete = false
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
        if !firstRunComplete {
            FirstRunView(firstRunComplete: $firstRunComplete)
        }
        else {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(Tab.home)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                CalendarView()
                    .tag(Tab.calendar)
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                TrophyPageView(showDummyData: false)
                    .tag(Tab.trophies)
                    .tabItem { Label("Trophies", systemImage: "trophy.fill") }
                VideosView()
                    .tag(Tab.videos)
                    .tabItem { Label("Videos", systemImage: "play.rectangle.fill") }
                SettingsView()
                    .tag(Tab.settings)
                    .tabItem { Label("Settings", systemImage: "person.circle.fill") }
            }
            .tint(.limeAccentColor)
        }
    }
}

extension Notification.Name {
    static let scrollToTop = Notification.Name("scrollToTop")
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(\.dynamicTypeSize, .medium)
        .preferredColorScheme(.light)
}
