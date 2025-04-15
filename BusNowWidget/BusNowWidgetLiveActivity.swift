//
//  BusNowWidgetLiveActivity.swift
//  BusNowWidget
//
//  Created by matsumotoryota on 2025/03/09.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BusNowWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BusNowWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusNowWidgetAttributes.self) { context in
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

extension BusNowWidgetAttributes {
    fileprivate static var preview: BusNowWidgetAttributes {
        BusNowWidgetAttributes(name: "World")
    }
}

extension BusNowWidgetAttributes.ContentState {
    fileprivate static var smiley: BusNowWidgetAttributes.ContentState {
        BusNowWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BusNowWidgetAttributes.ContentState {
         BusNowWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BusNowWidgetAttributes.preview) {
   BusNowWidgetLiveActivity()
} contentStates: {
    BusNowWidgetAttributes.ContentState.smiley
    BusNowWidgetAttributes.ContentState.starEyes
}
