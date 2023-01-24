//
//  WKWebView+Extensions.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 24.01.2023.
//

import WebKit

extension WKWebView {
    
    static func clean() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {  })
            }
        }
    }
}
