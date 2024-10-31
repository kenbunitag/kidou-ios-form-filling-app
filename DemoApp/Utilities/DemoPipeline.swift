//
//  DemoPipeline.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import Foundation
import KidouSdk


/// A wrapper for KidouSDK's transcription pipeline.
class DemoPipeline: ObservableObject {
    
    var pipeline: KidouPipeline
    private var httpHost: URL
    private var recorder: AudioRecorder?
    
    @Published var currentConfig: MatcherConfig = MatcherConfig([:])

    /// Initializes a new instance of the class.
    /// 
    /// - Parameters:
    ///   - onValue: A closure that will be called with the transcribed text.
    ///   - withPushInput: If true, use a native audio recorder to push audio samples to the pipeline. Else, let the pipeline handle the microphone input.
    init(
        onValue: @escaping (String) -> Void,
        withPushInput: Bool = false
    ) {
        let config = AppConfig()
        let websocketEndpoint = URL(string: "wss://\(config.host)/transcribe")!
        let httpHost = URL(string: "https://\(config.host)")!
        self.httpHost = httpHost

        try! setLicense(config.license)
        
        if withPushInput {
            let audioRecorder = AudioRecorder()
            let sampleRate = UInt32(audioRecorder.getSampleRate())
            let builder = try! KidouPipelineBuilder()
                .withPushInput(sampleRateHz: sampleRate, channelCount: 1)
                .withOnlineBackend(deviceId: "DemoApp", websocketUrl: websocketEndpoint.absoluteString)
            self.pipeline = try! builder.build(onValue: onValue, onError: onErrorCallback)
            audioRecorder.setCallback { samples in try! self.pipeline.writeSamples(samples)}
            self.recorder = audioRecorder
        } else {
            let builder = try! KidouPipelineBuilder()
                .withMicrophoneInput()
                .withOnlineBackend(deviceId: "DemoApp", websocketUrl: websocketEndpoint.absoluteString)
            self.pipeline = try! builder.build(onValue: onValue, onError: onErrorCallback)
        }  
    }
    
    func startProcessing() throws {
        try pipeline.startProcessing()
        recorder?.startRecording()
    }

    func stopProcessing() throws {
        try pipeline.stopProcessing()
        recorder?.stopRecording()
    }

    /// Set matcher config via REST API
    func setConfig(_ config: MatcherConfig) {
        
        let config_name = config.data["name"] as! String

        if NSDictionary(dictionary: config.data).isEqual(to: currentConfig.data) {
            print("Skip setting config, already set to \(config_name)")
            return
        }
        print("Setting matcher config: \(config_name)...")

        Task {
            do {
                let message = try await self.setMatcherConfig(host: httpHost, config: config.data)
                print("Set matcher config with response: \(message)")
                DispatchQueue.main.async {
                    self.currentConfig = config
                }
            } catch {
                print("Error setting matcher config: \(error)")
                return
            }
        }
    }
    
    /// Get the matcher configuration for the current session
    func getMatcherConfig(host: URL) async throws -> [String: Any] {
        let sessionId = try pipeline.getSessionId()
        let url = host.appendingPathComponent("sessions/\(sessionId)/matcher_config")
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error \(statusCode): \(errorMessage)"])
        }
        
        let jsonObject: [String: Any]
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        } catch {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON: \(error.localizedDescription)"])
        }
        return jsonObject
    }
    
    /// Set the matcher configuration for the current session.
    /// Alternative to sending it via the `sendCustomMetaJsonCommand` method,
    /// with the benefit of directly receiving a response.
    func setMatcherConfig(host: URL, config: [String: Any]) async throws -> String {
        let matcherConfig: [String: Any] = ["kind": "matcher_config", "value": config]

        let sessionId = try pipeline.getSessionId()
        let url = host.appendingPathComponent("sessions/\(sessionId)/ws_command")
        return try await makePutRequest(url: url, json: matcherConfig)
    }
}


func onErrorCallback(_ error: String) -> Void {
    print("Got Pipeline Error: \(error)")
}


func setLicense(_ license: String) throws {
    guard let licensePath = Bundle.main.path(forResource: license, ofType: "gpg") else {
        let message = "License file \(license).gpg not found. Please make sure to add you've added a valid license file to the project. Reach out to KENBUN support if you need help."
        throw NSError(domain: "DemoPipeline", code: 1, userInfo: ["message": message])
    }
    try KidouSdk.setLicense(licensePath: licensePath)
}


func makePutRequest(url: URL, json: [String: Any]) async throws -> String {
    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.httpBody = jsonData
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw NSError(domain: "KidouPipeline", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error \(statusCode): \(errorMessage)"])
    }
    
    if let responseString = String(data: data, encoding: .utf8) {
        return responseString
    } else {
        return "Command sent successfully"
    }
}
