//
//  PolynalApp.swift
//  Polynal
//
//  Created by Nakazawa Jakiya on 2024-12-25.
//

import SwiftUI

@main
struct PolynalApp: App {
  init() {
    EnvLoader.loadEnv()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
