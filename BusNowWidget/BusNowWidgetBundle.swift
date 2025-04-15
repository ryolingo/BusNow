//
//  BusNowWidgetBundle.swift
//  BusNowWidget
//
//  Created by matsumotoryota on 2025/03/09.
//

import WidgetKit
import SwiftUI

@main
struct BusNowWidgetBundle: WidgetBundle {
    var body: some Widget {
        BusNowWidget()
        BusNowWidgetControl()
        BusNowWidgetLiveActivity()
    }
}
