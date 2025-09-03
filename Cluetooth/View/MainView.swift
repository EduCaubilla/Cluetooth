//
//  ContentView.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query private var devices: [Device]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("My Devices")) {
    //                ForEach(devices) { device in
    //                    NavigationLink {
    //                        Text("\(device.name)")
    //                    } label: {
    //                        Text(device.name)
    //                    }
    //                }
    //                .onDelete(perform: deleteItems)
                    HStack {
                        Text("Device 1")

                        Spacer()

                        Button("Connect") {

                        }
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(.gray.opacity(0.2))
                        .clipShape(
                            Capsule()
                        )

                        Menu {
                            NavigationLink("Go to Detail") {
                                DetailView()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    .padding(.vertical, 3)
                } //: SECTION

                Section("Other Devices") {
                    HStack {
                        Text("Checking for new devices...")
                            .foregroundStyle(.gray)
                        Spacer()
                        ProgressView()
                    }
                } //: SECTION
            } //: LIST
            .listStyle(.grouped)
            .navigationTitle(Text("Cluetooth"))
            .navigationBarTitleDisplayMode(.inline)
        } //: NAV
    } //: VIEW
}

#Preview {
    MainView()
}
