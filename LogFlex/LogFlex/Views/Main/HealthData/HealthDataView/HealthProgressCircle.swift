//
//  HealthProgressCircle.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct HealthProgressCircle: View {
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        HealthDataView(healthKitManager: healthKitManager)
    }
}

