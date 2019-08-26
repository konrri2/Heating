

import Foundation

///in this form Config.plist must be
struct Config: Decodable {
    private enum CodingKeys: String, CodingKey {
        case HeatingSystemUrl, info
    }
    
    let HeatingSystemUrl: String
    let info: String
}

class ConfigManager {
    static func loadConfigTest() {
        
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
        }
    }
    
    static func parseConfig() -> Config {
        let url = Bundle.main.url(forResource: "Config", withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        guard let config = try? decoder.decode(Config.self, from: data) else {
            fatalError("No url for heating system - add Config.plist file")
        }
        return config
    }
}
