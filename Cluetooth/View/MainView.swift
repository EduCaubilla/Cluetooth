//
//  ContentView.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    //MARK: - PROPERTIES
    @Query private var devices: [Device]

    @ObservedObject var viewModel: MainViewModel

    //MARK: - INITIALIZER
    init(viewModel: MainViewModel = .init()) {
        self.viewModel = viewModel
    }

    //MARK: - BODY
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

                Section("Devices available") {
                    HStack {
                        if !viewModel.devicesReady && viewModel.connectionStatus == "Scanning..."  {
                            Text("Looking for new devices...")
                                .foregroundStyle(.gray)
                            Spacer()
                            ProgressView()
                        } else {
                            VStack(alignment: .leading) {
                                ForEach(viewModel.foundDevices) { device in
                                    Text(device.peripheral?.name ?? "Unknown Device")
                                }
                            }
                        }
                    }
                } //: SECTION
            } //: LIST
            .listStyle(.grouped)
            .navigationTitle(Text("Cluetooth"))
            .navigationBarTitleDisplayMode(.inline)

            Button("Scan for devices") {
                Task {
                    await viewModel.fetchDevices()
                }
            }
            .foregroundStyle(.blue)
            .font(.system(size: 25, weight: .medium, design: .default))
            .padding(.vertical, 15)
        } //: NAV
    } //: VIEW
}

//MARK: - PREVIEW
#Preview {
    MainView()
}
