//
//  ContentView.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import SwiftUI
import KidouSdk

struct MainTabview: View {

    @StateObject private var messageStore: MessageStore
    @StateObject private var pipeline: DemoPipeline
    
    init() {
        let messageStore = isPreview() ? MessageStore.createMock() : MessageStore()
        self._messageStore = StateObject(wrappedValue: messageStore)
        self._pipeline = StateObject(wrappedValue: DemoPipeline(onValue: messageStore.handleMessage, withPushInput: false))
    }
    
    var body: some View {
        TabView {   
            FormView(messageStore: messageStore, setConfigFn: pipeline.setConfig)
                .tabItem {
                    Label("Formular", systemImage: "doc.text")
                }
            LogsView(messageStore: messageStore)
                .tabItem {
                    Label("Transkripte", systemImage: "list.bullet")
                }
            ConfigView(config: pipeline.currentConfig)
                .tabItem {
                    Label("Matcher", systemImage: "gearshape")
                }
        }
        .environment(\.locale, .init(identifier: "de_DE"))
        .onAppear {
            if !isPreview() {
                DispatchQueue.global(qos: .utility).async {
                    try! pipeline.startProcessing()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabview()
    }
}
