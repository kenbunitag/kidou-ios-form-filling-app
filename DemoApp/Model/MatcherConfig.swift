//
//  MatcherConfig.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import Foundation

/// An observable object that holds the configuration for the matcher.
class MatcherConfig: ObservableObject {
    @Published var data: [String: Any]

    init(_ data: [String: Any]) {
        self.data = data
    }

    init(fromAsset name: String) {
        let path = Bundle.main.path(forResource: name, ofType: "json")!
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        self.data = json
    }

    func jsonString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
            return "Failed to convert data to JSON."
        }
        return String(data: jsonData, encoding: .utf8) ?? "Failed to convert data to JSON."
    }
}
