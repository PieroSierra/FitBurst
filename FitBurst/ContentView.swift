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
    //  case settings = "Settings"
}
 
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /*
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>*/

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





///Example for how to read and write from PersistentController

/*
 NavigationView {
 List {
 ForEach(items) { item in
 NavigationLink {
 Text("Item at \(item.timestamp!, formatter: itemFormatter)")
 } label: {
 Text(item.timestamp!, formatter: itemFormatter)
 }
 }
 .onDelete(perform: deleteItems)
 }
 .toolbar {
 ToolbarItem(placement: .navigationBarTrailing) {
 EditButton()
 }
 ToolbarItem {
 Button(action: addItem) {
 Label("Add Item", systemImage: "plus")
 }
 }
 }
 Text("Select an item")
 }
 
 
 
 private func addItem() {
 withAnimation {
 let newItem = Item(context: viewContext)
 newItem.timestamp = Date()
 
 do {
 try viewContext.save()
 } catch {
 // Replace this implementation with code to handle the error appropriately.
 // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 let nsError = error as NSError
 fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
 }
 }
 }
 
 private func deleteItems(offsets: IndexSet) {
 withAnimation {
 offsets.map { items[$0] }.forEach(viewContext.delete)
 
 do {
 try viewContext.save()
 } catch {
 // Replace this implementation with code to handle the error appropriately.
 // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 let nsError = error as NSError
 fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
 }
 }
 }
 }
 
 
 
 private let itemFormatter: DateFormatter = {
 let formatter = DateFormatter()
 formatter.dateStyle = .short
 formatter.timeStyle = .medium
 return formatter
 }()

 */
