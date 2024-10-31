import Foundation

class FormViewModel: ObservableObject {
    
    @Published var datum = Date()
    @Published var time = Date()
    @Published var krankheit = ""
    @Published var symptome = ""
    @Published var impfstatus = ""

    var krankheitOptions: [String] = []
    var impfstatusOptions: [String] = []
    
    let matcherConfig: MatcherConfig

    init() {
        self.matcherConfig = MatcherConfig(fromAsset: "matcher_config")
        self.krankheitOptions = getOption(config: matcherConfig.data, key: "krankheit")
        self.impfstatusOptions = getOption(config: matcherConfig.data, key: "impfstatus")
    }


    func processMatches(_ matches: [Match]) {
        for match in matches {
            print("Processing rule \(match.rule)...")
            switch match.rule {
                case "DATUM":
                    FH.fill(match.entities["date_or_time"], to: &self.datum, using: FH.fillDate)
                    FH.fill(match.entities["date_or_time"], to: &self.time, using: FH.fillTime)
                case "UHRZEIT": FH.fill(match.entities["time"], to: &time, using: FH.fillTime)
                case "KRANKHEIT": FH.fill(match.entities["krankheit"], to: &krankheit, using: FH.fillText)
                case "SYMPTOME": FH.fill(match.entities["symptome"], to: &symptome, using: FH.fillText)
                case "IMPFSTATUS": FH.fill(match.entities["impfstatus"], to: &impfstatus, using: FH.fillText)
                default: break
            }
        }
    }

    private func getOption(config: [String: Any], key: String) -> [String] {
        let fuzzy = config["fuzzy"] as! [String: Any]
        let lists = fuzzy["lists"] as! [String: Any]
        let list = lists[key] as! [String: Any]
        return [""] + list.keys.sorted()
    }
}
