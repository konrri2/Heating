import Foundation


class Thermostat: Hashable {
    static func == (lhs: Thermostat, rhs: Thermostat) -> Bool {
        return lhs.roomName == rhs.roomName
    }
    
    var hashValue: Int {
        return index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.roomName)
    }
    
    var roomName: String?  // /api/last returns no description
    var timestamp: Date?
    var temperature: Double?  //nil if thermostat is offline
    var setTemperature: Double?
    var isOn: Bool?
    var index: Int = -42
}

class RoomThermostat: Thermostat {
    var mode: String? //TODO enum
    
    init(
        roomName: String?,
        timestamp: Date?,
        temperature: Double?,
        setTemperature: Double?,
        isOn: Bool?,
        index: Int
        ) {
        super.init()
        self.roomName = roomName
        self.timestamp = timestamp
        self.temperature = temperature
        self.setTemperature = setTemperature
        self.isOn = isOn
        self.index = index
    }
}

class OutsideVirtualThermostat: Thermostat {
    var weatherDescription: String?
    
    init(
        timestamp: Date?,
        oudsideTemp: Double?,
        weatherDescription: String?
        ) {
        super.init()
        self.roomName = "Outside"
        self.index = -1
        self.timestamp = timestamp
        self.temperature = oudsideTemp
        self.weatherDescription = weatherDescription
    }
}

class CombiningVirtualThermostat: Thermostat {
    
    init(
        timestamp: Date?,
        toCombine: [RoomThermostat]
        ) {
        super.init()
        self.roomName = "Average"
        self.index = 10
        self.timestamp = timestamp
        temperature = calcAverage(toCombine)
    }
    
    private func calcAverage(_ toCombine: [RoomThermostat]) -> Double {
        var sum = 0.0
        var count = 0.0
        for r in toCombine {
            if let temp = r.temperature {
                sum += temp
                count += 1.0
            }
        }
        guard count > 0 else {
            fatalError("empty list of thermostats to average")
        }
        return sum/count
    }
}


