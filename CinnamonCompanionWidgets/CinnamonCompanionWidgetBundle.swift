//
//  CinnamonCompanionWidgetBundle.swift
//  CinnamonCompanionWidgets
//
//  File: CinnamonCompanionWidgets/CinnamonCompanionWidgetBundle.swift
//

import WidgetKit
import SwiftUI

@main
struct CinnamonCompanionWidgetBundle: WidgetBundle {
    var body: some Widget {
        UpcomingBookingWidget()
        StaySummaryWidget()
        StayDetailsWidget()
    }
}

