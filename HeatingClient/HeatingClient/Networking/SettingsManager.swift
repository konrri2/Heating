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
    
    private func buildCsvObservable(for url: URL) -> Observable<RoomsSettings> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)  //it is important not to cache
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
                        let sett = RoomSetting(name: cells[1],
                                               tempDay6: Double(cells[4]), tempDay22: Double(cells[5]),
                                               tempNight22: Double(cells[6]), tempNight6: Double(cells[7]))
                        roomSettArr.append(sett)
                    }
                }
                return RoomsSettings(roomSettArr)
            }.catchErrorJustReturn(RoomsSettings(error: "==== error for url \(url.absoluteString) ===="))
    }
    
}
