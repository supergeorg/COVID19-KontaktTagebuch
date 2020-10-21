//
//  KontakteView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct KontakteView: View {
    let store = PersistentStore.shared
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchKontakte()) var kontakte: FetchedResults<Kontakt>
    
    @State private var showAddKontakt = false
    
    var body: some View {
        NavigationView(){
            List{
                if kontakte.isEmpty {
                    Text("Noch keine Kontakte eingetragen.").padding()
                }
                ForEach(kontakte, id:\.id){kontakt in
                    NavigationLink(destination: KontaktDetailView(kontakt: kontakt, isReadOnly: false)) {
                        KontaktItemView(kontakt: kontakt)
                    }
                }
            }
            .animation(.default)
            .navigationBarTitle("Kontakte")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {showAddKontakt = true}, label: {Image(systemName: "text.badge.plus")})
                }
            }
        }
        .sheet(isPresented: self.$showAddKontakt, content: {KontaktAddFormView(isShown: self.$showAddKontakt).environment(\.managedObjectContext, self.moc)})
    }
}

struct KontakteView_Previews: PreviewProvider {
    static var previews: some View {
        KontakteView().environment(\.managedObjectContext, PersistentStore.preview.persistentContainer.viewContext)
    }
}
