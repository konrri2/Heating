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
    
    //TODO test it
    func clearCache() {
        URLSessionConfiguration.default.urlCache = nil
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
