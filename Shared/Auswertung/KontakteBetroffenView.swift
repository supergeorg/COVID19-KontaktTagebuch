//
//  KontakteBetroffenView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 18.08.20.
//

import SwiftUI
import CoreData

struct KontakteBetroffenView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest var kontakte: FetchedResults<Kontakt>
    
    var startDate : Date
    var endDate : Date
    @Binding var isShown: Bool
    
    init(startDate: Date, endDate: Date, isShown: Binding<Bool>) {
        self.startDate = startDate
        self.endDate = endDate
        self._kontakte = FetchRequest(fetchRequest: PersistentStore.shared.fetchKontakteBetweenDates(startDate: startDate, endDate: endDate), animation: .default)
        self._isShown = isShown
    }
    
    private func gatherPersons() -> Set<Person> {
        var betroffenePersonen = Set<Person>()
        for kontakt in kontakte {
            for person in kontakt.personen!{
                betroffenePersonen.insert(person as! Person)
            }
        }
        return betroffenePersonen
    }
    
    var body: some View {
        NavigationView(){
            Form{
                Section(header: Text("Info")){
                    Label("Auf dieser Seite werden alle Kontakte im angegebenen Zeitraum aufgelistet.", systemImage: "info.circle")
                    Label(formatDate(date2format: self.startDate), systemImage: "calendar.badge.plus")
                    Label(formatDate(date2format: self.endDate), systemImage: "calendar.badge.minus")
                }
                Section(header: Text("Kontakte")){
                    if kontakte.isEmpty {
                        Text("Keine Kontakte im Zeitraum.")
                    }
                    ForEach(kontakte, id:\.id) {kontakt in
                        NavigationLink(destination: KontaktDetailView(kontakt: kontakt, isReadOnly: true)) {
                            KontaktItemView(kontakt: kontakt)
                        }
                    }
                }
                Section(header: Text("Personen / Gruppen")){
                    if gatherPersons().isEmpty {
                        Text("Keine betroffenen Personen im Zeitraum.")
                    }
                    ForEach(Array(gatherPersons()), id: \.self) {person in
                        NavigationLink(destination: PersonDetailView(person: person, isFavourite: person.favourite, isReadOnly: true)) {
                            PersonItemView(person: person, isFavourite: person.favourite)
                        }
                    }
                }
            }
            .navigationBarTitle("Betroffene Kontakte")
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        self.isShown = false
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
            })
        }
    }
}

struct KontakteBetroffenView_Previews: PreviewProvider {
    static var previews: some View {
        KontakteBetroffenView(startDate: Date(), endDate: Calendar.current.date(byAdding: .weekOfYear, value: 2, to: Date())!, isShown: Binding.constant(true))
    }
}
