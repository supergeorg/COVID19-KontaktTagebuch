//
//  AnalyzeView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 18.08.20.
//

import SwiftUI

struct AnalyzeView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchKontakte()) var kontakte: FetchedResults<Kontakt>
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
    
    @State private var infektionsDatum: Date = Calendar.current.startOfDay(for: Date())
    @State var showBetroffene: Bool = false
    
    private func timeSpend() -> Double {
        var time = 0.0
        for kontakt in kontakte {
            time = time + kontakt.duration
        }
        return time
    }
    
    var body: some View {
        Form{
            Section(header: Text("Statistik")){
                Label("\(kontakte.count) aufgezeichnete Kontakte", systemImage: "list.number")
                Label("\(personen.count) gespeicherte Personen", systemImage: "rectangle.stack.person.crop")
                Label("\(formatDuration(duration2format: timeSpend())) mit Kontakten verbracht", systemImage: "clock")
            }
            Section(header: Text("Kontaktrückverfolgung")){
                Text("Die Kontaktrückverfolgung hat das Ziel, im Falle einer Infektion alle möglicherweise Infizierten zu finden und zu informieren. Dafür wird der frühest mögliche Zeitpunkt der Infektiösität angegeben und in der darauffolgenden Zeit alle Kontakte aufgelistet.")
                DatePicker("Datum", selection: $infektionsDatum, displayedComponents: .date)
                Button(action: {
                    self.showBetroffene = true
                }, label: {
                    Label("Alle Kontakte ab oberen Datum anzeigen", systemImage: "person.2.square.stack")
                        .foregroundColor(.red)
                }).sheet(isPresented: self.$showBetroffene, content: {KontakteBetroffenView(startDate: infektionsDatum, endDate: Calendar.current.date(byAdding: .weekOfYear, value: 2, to: infektionsDatum)!, isShown: self.$showBetroffene).environment(\.managedObjectContext, self.moc)})
            }
            Section(header: Text("Export")){
                Text("Für eine anderweitige Nutzung und für Sicherungszwecke kann")
            }
        }
    }
}

struct AnalyzeView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzeView()
    }
}
