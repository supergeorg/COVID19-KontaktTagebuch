//
//  InfoView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 18.08.20.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack(alignment: .center){
            Text("COVID-19 Kontakt-Tagebuch").font(.headline)
            Divider()
            Text("Die Aufgabe dieser App ist es, die Führung eines Kontakttagebuchs zu vereinfachen. Dies wurde von Prof. Drosten für den Herbst empfohlen, um im Falle einer Infektion alle möglichen Kontaktpersonen finden und informieren zu können.").font(.body)
            Spacer()
            Group{
                Divider()
                Text("Diese App wurde 2020 von Georg Meißner entwickelt.").font(.caption)
                HStack{
                    Image(systemName: "swift").font(.largeTitle)
                    Image(systemName: "applelogo").font(.largeTitle)
                    Image(systemName: "laptopcomputer").font(.largeTitle)
                }
                Text("Geschrieben in Swift und SwiftUI auf einem MacBook.").font(.caption)
                Link(destination: URL(string: "https://github.com/supergeorg/COVID19-KontaktTagebuch/")!) {
                    Label("Projekt auf Github ansehen", systemImage: "network")
                }
                Divider()
                Spacer()
            }
            Text("Trage bei Kontakten möglichst eine Mund-Nase-Bedeckung und halte den Mindestabstand ein!").font(.body)
            HStack{
                Image(systemName: "nose").font(.largeTitle)
                Image(systemName: "mouth").font(.largeTitle)
                Image(systemName: "person.and.arrow.left.and.arrow.right").font(.largeTitle)
            }
            Text("Bleib sicher!").font(.body)
        }.padding().labelsHidden()
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
