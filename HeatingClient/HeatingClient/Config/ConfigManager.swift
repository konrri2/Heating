

import Foundation

///in this form Config.plist must be
struct Config: Decodable {
    private enum CodingKeys: String, CodingKey {
        case remoteAddress, localAddress, info
    }

    let localAddress: String
    let remoteAddress: String
    let info: String

    var HeatingSystemUrl: String {
        return localAddress //TODO chose which one works
    }
    
    var lastMeasurementUrl: String {
        return HeatingSystemUrl+"/api/last"
    }
    
    var allMeasurementsUrl: String {
        return HeatingSystemUrl+"/api/all"
    }
}

class ConfigManager {

    static func parseConfig() -> Config {
        if let mainConfig = parseConfig(filename: "Config") {
            return mainConfig
        }
        else if let testConfig = parseConfig(filename: "Config_debug") {
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
