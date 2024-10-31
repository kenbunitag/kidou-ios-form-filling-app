//
//  ConfigView.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import SwiftUI

struct ConfigView: View {

    @ObservedObject var config: MatcherConfig


    var body: some View {
        NavigationView {
            VStack() {
                TextEditor(text: .constant(config.jsonString()))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.caption, design: .monospaced))
                    .padding(3)
                    .background(Color(.white))
                    .cornerRadius(10)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Aktuelle Konfiguration")
        }
        .onAppear {}
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(config: MatcherConfig(fromAsset: "matcher_config_author"))
    }
}
