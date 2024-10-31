//
//  MatcherConfig.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import Foundation
import Combine


/// Holds the transcriptions and matches that are received from the WebSocket.
class MessageStore: ObservableObject {
    @Published var transcriptions: [Transcription] = []
    @Published var newMatches: [Match] = []

    func parseMessage(_ message: String) {
        if let response = parseTranscriptionResponse(from: message) {
            let newTranscription = Transcription(text: response.transcription, time: Date())
            transcriptions.append(newTranscription)
            if !response.matches.isEmpty {
                newMatches = response.matches
            }
        }
        else {
            print("Got non-transcription websocket message: \(message)")
        }
    }
    
    func handleMessage(_ message: String) {
        DispatchQueue.main.async {
            self.parseMessage(message)
        }
    }

    func parseTranscriptionResponse(from json: String) -> TranscriptionResponse? {
        let data = json.data(using: .utf8)!
        guard let outerResponse = try? JSONDecoder().decode(OuterResponse.self, from: data) else {
            return nil
        }
        return outerResponse.value
    }

    static func createMock() -> MessageStore {
        let messageStore = MessageStore()
        messageStore.transcriptions = [
            Transcription(text: "hallo ich bin ein test text", time: Date()),
            Transcription(text: "hallo ich bin ein anderer test text", time: Date().addingTimeInterval(1))
        ]
        
        return messageStore
    }
}


struct Transcription: Equatable{
    var text: String
    var time: Date
}


struct OuterResponse: Decodable {
    var kind: String
    var value: TranscriptionResponse
}


struct TranscriptionResponse: Decodable {
    var transcription: String
    var score: Double
    var vadData: VadData
    var matches: [Match]
    
    private enum CodingKeys: String, CodingKey {
        case transcription
        case score
        case vadData = "vad_data"
        case matches
    }
}


struct VadData: Decodable {
    var startSecs: Double
    var endSecs: Double
    var durationSecs: Double
    var startSample: Int
    var endSample: Int

    private enum CodingKeys: String, CodingKey {
        case startSecs = "start_secs"
        case endSecs = "end_secs"
        case durationSecs = "duration_secs"
        case startSample = "start_sample"
        case endSample = "end_sample"
    }
}


struct Match: Identifiable, Decodable {
    var id = UUID()
    var rule: String
    var matchedText: String
    var matchedPattern: String
    var matchedPatternRaw: String
    var matchScore: Double
    var configName: String
    var span: [Int]
    var entities: [String: Entity]

    private enum CodingKeys: String, CodingKey {
        case rule
        case matchedText = "matched_text"
        case matchedPattern = "matched_pattern"
        case matchedPatternRaw = "matched_pattern_raw"
        case matchScore = "match_score"
        case configName = "config_name"
        case span
        case entities
    }
}


enum Entity: Decodable {
    case number(NumberEntity)
    case datetime(DatetimeEntity)
    case text(TextEntity)

    private enum CodingKeys: String, CodingKey {
        case kind
    }
    // NOTE: The WebSocket returns internally tagged enum serialization, which does not seem to be known to Swift
    // https://serde.rs/enum-representations.html#internally-tagged
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)


        switch kind {
        case "number":
            let numberEntity = try NumberEntity(from: decoder)
            self = .number(numberEntity)
        case "datetime":
            let datetimeEntity = try DatetimeEntity(from: decoder)
            self = .datetime(datetimeEntity)
        case "text":
            let textEntity = try TextEntity(from: decoder)
            self = .text(textEntity)
        default:
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.kind, in: container, debugDescription: "Unexpected kind value")
        }
    }
}


struct NumberEntity: Decodable {
    var number: Double
    var kind: String // always "number"
}


struct DatetimeEntity: Decodable {
    var year: Int?
    var month: Int?
    var day: Int?
    var hour: Int?
    var minute: Int?
    var kind: String // always "datetime"
}


struct TextEntity: Decodable {
    var text: String
    var kind: String  // always "text"
}
