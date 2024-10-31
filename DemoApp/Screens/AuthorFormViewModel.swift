//
//  AuthorFormViewModel.swift
//  DemoApp
//
//  Created by Matthias Dunkelberg on 02.12.24.
//

import Foundation

class AuthorFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var geburtsdatum: Date = Date()
    @Published var adresse: String = ""
    @Published var telefon: String = ""

    let matcherConfig = MatcherConfig(fromAsset: "matcher_config_author")
    
    func processMatches(_ matches: [Match]) {
        for match in matches {
            print("Processing rule \(match.rule)...")
            switch match.rule {
            case "NAME": 
                FH.fill(match.entities["text"], to: &name, using: FH.fillText)
                name = FH.capitalizeWords(name)
            case "GEBURTSDATUM": FH.fill(match.entities["date"], to: &geburtsdatum, using: FH.fillDate)
            case "ADRESSE": FH.fill(match.entities["text"], to: &adresse, using: FH.fillText)
            case "TELEFONNUMMER":
                FH.fill(match.entities["phone"], to: &telefon, using: FH.fillText)
                telefon = FH.formatPhone(telefon)
            default: break
            }
        }
    }
}
