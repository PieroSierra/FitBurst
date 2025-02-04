//
//  FitBurst_WidgetLiveActivity.swift
//  FitBurst Widget
//
//  Created by Piero Sierra on 01/02/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FitBurst_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FitBurst_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FitBurst_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FitBurst_WidgetAttributes {
    fileprivate static var preview: FitBurst_WidgetAttributes {
        FitBurst_WidgetAttributes(name: "World")
    }
}

extension FitBurst_WidgetAttributes.ContentState {
    fileprivate static var smiley: FitBurst_WidgetAttributes.ContentState {
        FitBurst_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FitBurst_WidgetAttributes.ContentState {
         FitBurst_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FitBurst_WidgetAttributes.preview) {
   FitBurst_WidgetLiveActivity()
} contentStates: {
    FitBurst_WidgetAttributes.ContentState.smiley
    FitBurst_WidgetAttributes.ContentState.starEyes
}
