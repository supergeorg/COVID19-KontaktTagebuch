//
//  PersonItemView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct PersonItemView: View {
    var person: Person
    
    @State var isFavourite: Bool
    
    var body: some View {
        HStack{
            if person.isgroup {
                Image(systemName: "person.3")
                Text(person.groupname ?? "kein Gruppenname")
            } else {
                Image(systemName: "person")
                Text("\(person.vorname ?? "kein Vorame") \(person.nachname ?? "kein Nachname")")
            }
            if person.favourite {
                Spacer()
                Image(systemName: "star.fill")
            }
        }
    }
}

struct PersonItemView_Previews: PreviewProvider {
    static var previews: some View {
        PersonItemView(person: Person(), isFavourite: true)
    }
}
