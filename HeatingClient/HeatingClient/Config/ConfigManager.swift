

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
    static func loadConfigTest() -> NSDictionary? {
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
        }
        return nsDictionary
    }
    
    static func parseConfig() -> Config {
        if let mainConfig = ConfigManager.parseConfig(filename: "Config") {
            return mainConfig
        }
        else if let testConfig = ConfigManager.parseConfig(filename: "Config_debug") {
            logWarn("Could not load main Config.plist file, used Config_debug instead")
            return testConfig
        }
        else {
            fatalError("You mast add Config.plist (Config_debug.plist) with 'HeatingSystemUrl' value")
        }
    }
    
    
    static func parseConfig(filename: String) -> Config? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "plist"),
                let data = try? Data(contentsOf: url),
                let config = try? PropertyListDecoder().decode(Config.self, from: data) else {
                return nil
        }
        return config
    }
}
