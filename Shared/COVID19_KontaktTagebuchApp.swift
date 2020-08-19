//
//  COVID19_KontaktTagebuchApp.swift
//  Shared
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

@main
struct COVID19_KontaktTagebuchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, PersistentStore.shared.persistentContainer.viewContext)
        }
    }
}
