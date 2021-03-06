//
//  KontaktItemView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct KontaktItemView: View {
    var kontakt: Kontakt
    var body: some View {
        VStack(alignment: .leading){
            Text(kontakt.title ?? "").font(.title)
            Text(formatDate(date2format: kontakt.date ?? Date())).font(.caption)
//            Text("\(kontakt.personen?.count ?? 0) Personen")
            Text("\((kontakt.personen?.count ?? 0 > 0) ? "\(kontakt.personen?.count ?? 0)" : "Unbekannte") Personen")
        }
    }
}

struct KontaktItemView_Previews: PreviewProvider {
    static var previews: some View {
        KontaktItemView(kontakt: Kontakt())
    }
}
