//
//  Config.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import Foundation


class AppConfig {
    let host = ""
    let license = ""

    /// Checks if the values are set
    init() {
        if self.host.isEmpty {
            fatalError("Please set the 'host' url in Config.swift, e.g. 'cloud.kenbun.de/dummy'")
        }
        if self.license.isEmpty {
            fatalError("Please set the 'license' file in Config.swift, e.g. 'my-license-2026-01-01'")
        }
    }
}
