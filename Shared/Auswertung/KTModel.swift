//
//  KTModel.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 21.10.20.
//

import Foundation

struct ExportKT: Codable {
    let title: String
    let date: Date
    let personen: ExportPersonen?
    let kontakte: ExportKontakte?
}

struct ExportPerson: Codable {
    let groupName: String?
    let nachName, vorName: String?

    enum CodingKeys: String, CodingKey {
        case groupName = "group_name"
        case nachName = "nachname"
        case vorName = "vorname"
    }
}

typealias ExportPersonen = [ExportPerson]

struct ExportKontakt: Codable {
    let title: String
    let date: Date
    let duration: Double?
    let isOutdoor: Bool?
    let location: String?
    
    enum CodingKeys: String, CodingKey {
        case title, date, duration
        case isOutdoor = "is_outdoor"
        case location
    }
}

typealias ExportKontakte = [ExportKontakt]
