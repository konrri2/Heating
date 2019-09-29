

import Foundation

///in this form Config.plist must be
struct Config: Decodable {
    private enum CodingKeys: String, CodingKey {
        case remoteAddress, localAddress, info
    }

    let localAddress: String
    let remoteAddress: String
    let info: String
    
    func lastMeasurementUrl(local: Bool) -> String {
        if local {
            return localAddress + "/api/last"
        } else {
            return remoteAddress + "/api/last"
        }
    }
    
    func allMeasurementsUrl(local: Bool) -> String {
        if local {
            return localAddress + "/api/all"
        } else {
            return remoteAddress + "/api/all"
        }
    }
    
    func getSettingsUrl(local: Bool) -> String {
        if local {
            return localAddress + "/api/getSettings"
        } else {
            return remoteAddress + "/api/getSettings"
        }
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
