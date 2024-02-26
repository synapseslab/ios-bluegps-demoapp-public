//
//  DemoApp.swift
//  DemoApp
//
//  Created by Costantino Pistagna on 02/02/24.
//

import SwiftUI
import SynapsesSDK

@main
struct DemoApp: App {
    @StateObject private var sdkViewModel = SDKViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    sdkViewModel.commonInit()
                }
        }
        .environmentObject(sdkViewModel)
    }
}
