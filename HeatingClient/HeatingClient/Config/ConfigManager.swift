

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
    
    static func parseConfig() -> Config? {
        var url = Bundle.main.url(forResource: "Config2", withExtension: "plist")
        if url == nil {
            url = Bundle.main.url(forResource: "Config_debug", withExtension: "plist")
        }
        guard let fileUrl = url else {
            fatalError("No Config.plist file (nor Config_debug.plist)")
        }
        guard let data = try? Data(contentsOf: fileUrl) else {
            fatalError("No data in config file")
        }
        let decoder = PropertyListDecoder()
        guard let config = try? decoder.decode(Config.self, from: data) else {
            fatalError("No url for heating system - add Config.plist file")
        }
        return config
    }
}
