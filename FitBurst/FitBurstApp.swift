//
//  FitBurstApp.swift
//  FitBurst
//
//  Created by Nikola Sierra on 24/11/2024.
//

import SwiftUI

@main
struct FitBurstApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
