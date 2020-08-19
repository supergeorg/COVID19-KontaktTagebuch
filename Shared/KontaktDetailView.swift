//
//  KontaktDetailView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct KontaktDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var kontakt: Kontakt
    var isReadOnly: Bool
    
    @State private var showDeleteSheet: Bool = false
    
    private var deleteContactAS: ActionSheet {
        ActionSheet(title: Text("Kontakt löschen"),
                    message: Text("Mit dieser Aktion wird der entsprechende Kontakt gelöscht. Der Vorgang ist irreversibel."),
                    buttons: [
                        .destructive(Text("Löschen"), action: {
                            PersistentStore.shared.deleteKontakt(kontakt: kontakt)
                            self.presentationMode.wrappedValue.dismiss()
                        }),
                        .cancel()
                    ]
        )
    }
    
    private struct KontaktPersonView: View {
        var kontaktpersonen: Set<Person>
        
        var body: some View {
            Section(header: Text("Personen / Gruppen")){
                if kontaktpersonen.count == 0 {
                    Label("Keine Personen für diesen Kontakt aufgezeichnet.", systemImage: "xmark.circle")
                }
                ForEach(Array(kontaktpersonen), id: \.self) {person in
                    HStack{
                        if person.isgroup {
                            Label(person.groupname ?? "Error: Groupname", systemImage: "person.3")
                        } else {
                            Label("\(person.vorname ?? "Error: Vorname") \(person.nachname ?? "Error: Nachname")", systemImage: "person")
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView(){
            Form {
                Section(header: Text("Allgemeines")){
                    Label(kontakt.title ?? "kein Titel", systemImage: "textbox")
                }
                Section(header: Text("Zeit")){
                    Label(formatDate(date2format: kontakt.date), systemImage: "calendar")
                    Label(formatDuration(duration2format: kontakt.duration), systemImage: "clock")
                }
                KontaktPersonView(kontaktpersonen: (kontakt.personen ?? Set<Person>() as NSSet) as! Set<Person>)
                Section(header: Text("Art des Kontakts")){
                    if kontakt.outdoor {
                        Label("Kontakt fand Draußen statt.", systemImage: "checkmark.shield")
                            .foregroundColor(.green)
                    } else {
                        Label("Kontakt fand in einem Innenraum statt.", systemImage: "xmark.shield")
                            .foregroundColor(.red)
                    }
                }
                if !isReadOnly {
                    Button(action: {
                        showDeleteSheet = true
                    }, label: {
                        Label("Kontakt löschen", systemImage: "trash")
                            .foregroundColor(.red)
                    }).actionSheet(isPresented: $showDeleteSheet, content: {
                        self.deleteContactAS
                    })
                }
            }
        }
        .navigationBarTitle("Kontakt")
    }
}

struct KontaktDetailView_Previews: PreviewProvider {
    static var previews: some View {
        KontaktDetailView(kontakt: Kontakt(), isReadOnly: false)
    }
}
