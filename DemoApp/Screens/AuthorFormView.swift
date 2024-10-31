//
//  AuthorFormView.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import Foundation
import SwiftUI

struct AuthorFormView: View {
    @StateObject private var model = AuthorFormViewModel()
    var messageStore: MessageStore
    private var setConfigFn: (MatcherConfig) -> Void

    init(messageStore: MessageStore, setConfigFn: @escaping (MatcherConfig) -> Void) {
        self.messageStore = messageStore
        self.setConfigFn = setConfigFn
    }
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Name", text: $model.name)
                DatePicker("Geburtsdatum", selection: $model.geburtsdatum, displayedComponents: .date)
                TextField("Adresse", text: $model.adresse)
                TextField("Telefon", text: $model.telefon)
            }
        }
        .navigationTitle("Meldende Person")
        .onReceive(messageStore.$newMatches) { matches in
                model.processMatches(matches)
            }
        .onAppear {
            setConfigFn(model.matcherConfig)
        }
    }
}

struct AuthorFormView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorFormView(messageStore: MessageStore.createMock(), setConfigFn: { _ in })
    }
}
