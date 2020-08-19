//
//  ContentView.swift
//  Shared
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

func formatDate(date2format: Date?) -> String {
    let df = DateFormatter()
    df.locale = Locale(identifier: "de-DE")
    df.dateFormat = "E, dd.MM.yyyy, HH:mm"
    return date2format == nil ? "Fehler" : df.string(from: date2format!) 
}

func formatDuration(duration2format: Double) -> String {
    let dcf = DateComponentsFormatter()
    dcf.allowedUnits = [.hour, .minute]
    dcf.unitsStyle = .abbreviated
    return dcf.string(from: duration2format) ?? "Fehler"
}

enum enum_contactType {
    case privatemeet
    case eatingout
    case gathering
    case sport
}

struct ContentView: View {
    @State var tabSelection = 1
    var body: some View {
        TabView(selection: $tabSelection) {
            KontakteView().tabItem {
                VStack{
                    Image(systemName: "list.bullet.rectangle")
                    Text("Kontakte")
                }
            }.tag(1)
            PersonenView().tabItem {
                VStack{
                    Image(systemName: "person.3.fill")
                    Text("Personen")
                }
            }.tag(2)
            AnalyzeView().tabItem {
                VStack{
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                    Text("Auswertung")
                }
            }.tag(3)
            InfoView().tabItem {
                VStack{
                    Image(systemName: "info.circle")
                    Text("Über")
                }
            }.tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
