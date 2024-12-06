//
//  LogsView.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import SwiftUI

struct LogsView: View {
    @ObservedObject var messageStore: MessageStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messageStore.transcriptions.reversed(), id: \.self.time) { transcription in
                        VStack(alignment: .leading) {
                            Text("TRANSCRIPT")
                                .font(.caption)
                                .padding(.bottom, 1)
                                .foregroundColor(.secondary)
                            Text(transcription.text)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(10)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
            }
            .navigationTitle("Transkripte")
        }
    }
}


struct LogsView_Previews: PreviewProvider {
    static var previews: some View {
        LogsView(messageStore: MessageStore.createMock())
    }
}
