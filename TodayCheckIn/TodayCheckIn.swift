//
//  TodayCheckIn.swift
//  TodayCheckIn
//
//  Created by holybeta on 2020/6/28.
//  Copyright © 2020 JohnConner. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    public typealias Entry = DateEntry
    
    func placeholder(in context: Context) -> DateEntry {
        DateEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DateEntry) -> Void) {
        let entry = DateEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DateEntry>) -> Void) {
        let currentDate = Date()
        let timeline = Timeline(entries: [DateEntry(date: currentDate)], policy: .atEnd)
        completion(timeline)
    }
    
}

struct DateEntry: TimelineEntry {
    public let date: Date
    let ban: Ban = Ban()
    init(date: Date) {
        self.date = date
        ban.reload()
    }
}

struct PlaceholderView : View {
    var body: some View {
        TodayCheckInEntryView(entry: Provider.Entry(date: Date()))
    }
}

struct TodayCheckInEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(54)
                .frame(width: 108, height: 108)
                .foregroundColor(entry.ban.todayCheckIn ? .red:.blue)
                .opacity(0.8)
                .shadow(radius: 4)
                .animation(Animation.easeOut)
            Text(entry.ban.todayCheckIn ? "已签到":"签到")
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(nil)
        }
    }
}

@main
struct TodayCheckIn: Widget {
    private let kind: String = "TodayCheckIn"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayCheckInEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Today Check in Status Widget")
        .description("Check your check state widget.")
    }
}

struct TodayCheckIn_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TodayCheckInEntryView(entry: Provider.Entry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            PlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
