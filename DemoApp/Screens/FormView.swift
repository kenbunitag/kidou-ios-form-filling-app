//
//  FormView.swift
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import SwiftUI
import KidouSdk

struct FormView: View {
    
    @StateObject private var model = FormViewModel()
    
    private var messageStore: MessageStore
    private var setConfigFn: (MatcherConfig) -> Void
    

    init(messageStore: MessageStore, setConfigFn: @escaping (MatcherConfig) -> Void) {
        self.messageStore = messageStore
        self.setConfigFn = setConfigFn
    }
    
    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("Meldende Person")) {
                    NavigationLink(destination: AuthorFormView(messageStore: messageStore, setConfigFn: setConfigFn)) {
                        Text("Angaben")
                    }
                }

                Section(header: Text("Datum der Meldung")) {
                    DatePicker("Datum", selection: $model.datum, displayedComponents: .date)
                    DatePicker("Uhrzeit", selection: $model.time, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Betroffene Person")) {
                    Picker("Krankheit", selection: $model.krankheit) {
                        ForEach(model.krankheitOptions, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    TextField("Symptome (Freitext)", text: $model.symptome)
                }
                
                Section(header: Text("Bei impfpreväntablen Krankheiten")) {
                    Picker("Impfstatus", selection: $model.impfstatus) {
                        ForEach(model.impfstatusOptions, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                }
            }
            .navigationTitle("Formular")
            .onReceive(messageStore.$newMatches) { matches in
                model.processMatches(matches)
            }
            .onAppear {
                setConfigFn(model.matcherConfig)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())    
    }
}
    

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView(messageStore: MessageStore(), setConfigFn: { _ in })
    }
}
