//
//  SettingsManager.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 29/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingsManager {
    
    let config: Config
    init() {
        config = ConfigManager.parseConfig()
    }
    
    func loadSettings() -> Observable<RoomsSettings> {
        guard let localUrl = URL(string: config.getSettingsUrl(local: true)) else {
            fatalError("config.getSettingsUrl(local: true): \(config.getSettingsUrl(local: true)) is not a correct url for heating system")
        }
        guard let remoteUrl = URL(string: config.getSettingsUrl(local: false)) else {
            fatalError("config.getSettingsUrl(local: true): \(config.getSettingsUrl(local: true)) is not a correct url for heating system")
        }
        
        let obsLocal = buildCsvObservable(for: localUrl)
        let obsRemote = buildCsvObservable(for: remoteUrl)
        
        return Observable
            .merge(obsLocal,obsRemote)
    }
    
    //TODO -check, because this does not work as expected
    func clearCache() {
        URLSessionConfiguration.default.urlCache = nil
    }
    
    func applySettings() {
        let json: [String: Any] = ["room": "Guest",
                                   "new": "7,7,7,7",
                                   "old": "8,8,8,8"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: "http://localhost:8090/api/changeSetting")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                log("===========response =")
                print(httpResponse.statusCode)
                if let responseString = String(bytes: data, encoding: .utf8) {
                    // The response body seems to be a valid UTF-8 string, so print that.
                    print(responseString)
                }
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
    }
    
    private func buildCsvObservable(for url: URL) -> Observable<RoomsSettings> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 900)
                return URLSession.shared.rx.data(request: request)
            }.map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: "\n")
                return strArr
            }.map { strArr -> RoomsSettings in
                var roomSettArr = [RoomSetting]()
                for dataRow in strArr {
                    let cells = dataRow.components(separatedBy: ",")
                    if cells.count >= 8 {
                        let sett = RoomSetting(cells)
                        roomSettArr.append(sett)
                    }
                }
                return RoomsSettings(roomSettArr)
            }.catchErrorJustReturn(RoomsSettings(error: "==== error for url \(url.absoluteString) ===="))
    }
    
    
}
