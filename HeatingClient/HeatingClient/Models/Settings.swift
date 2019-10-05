//
//  Settings.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 29/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation


/** setting file example
 "0", "Main bedroom", "room1", "xxxx", 19.0, 17.5, 17.5, 21.0,
 "1", "Bathroom", "room2", "9b19", 20.0, 19.0, 23.0, 24.0,
 "2", "Guest room", "room3", "9c38", 19.0, 17.5, 18.0, 21.5,
 "3", "Agata's", "room4", "9c12", 19.0, 17.5, 18.0, 21.0,
 "4", "Leo's'", "room5", "ac61", 19.0, 17.5, 18.0, 21.0,
 "5", "Living room", "room6", "aada", 19.0, 18.0, 19.0, 21.0,
 "6", "Kitchen", "room7", "9a3b", 19.0, 18.0, 19.0, 21.0,
 "7", "Office", "room8", "9c8a", 16.0, 14.0, 18.0, 16.0,  
 */
struct RoomSetting {
    var name: String?
    var tempDay6: Double?
    var tempDay22: Double?
    var tempNight22: Double?
    var tempNight6: Double?
       
    //NOTE: names came with spaces and quotes
    init(_ cells: [String]) {
        name = cells[1].replacingOccurrences(of: "\"", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
        
        tempDay6 = Double(cells[4].trimmingCharacters(in: .whitespacesAndNewlines))
        tempDay22 = Double(cells[5].trimmingCharacters(in: .whitespacesAndNewlines))
        tempNight22 = Double(cells[6].trimmingCharacters(in: .whitespacesAndNewlines))
        tempNight6 = Double(cells[7].trimmingCharacters(in: .whitespacesAndNewlines))
        
        //TODO newSettings = [tempDay6, tempDay22, tempNight22, tempNight6]
    }
}

struct RoomsSettings {
    var errorInfo: String?
    var dict = [String: RoomSetting]()
    
    init(_ arr: [RoomSetting]) {
        for room in arr {
            if let name = room.name {
                dict[name] = room
            }
        }
    }
    init(error: String) {
        errorInfo = error
    }
    
    subscript(key_roomName: String) -> RoomSetting? {
        get {
            return dict[key_roomName]
        }
    }
}
