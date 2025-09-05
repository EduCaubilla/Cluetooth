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
                    // TODO - List of already connected devices from local db
                    // Example cell
                    HStack {
                        Text("Device 1")

                        Spacer()

                        Button("Connect") {

                        } //: BUTTON
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(.gray.opacity(0.15))
                        .clipShape(
                            Capsule()
                        )

                        Menu {
                            NavigationLink("Info") {
                                DetailView()
                            }
                            Button("Remove") {
                                print("Remove device")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        } //: MENU
                    } //: HSTACK
                    .padding(.vertical, 3)
                } //: SECTION

                Section("Devices available") {
                    if viewModel.foundDevices.isEmpty {
                        Text("No devices found")
                            .foregroundStyle(.gray)
                    } else {
                        HStack {
                            if viewModel.connectionStatus == "Scanning..."  {
                                Text("Looking for new devices...")
                                    .foregroundStyle(.gray)
                                Spacer()
                                ProgressView()
                            } else {
                                VStack(alignment: .leading) {
                                    ForEach(viewModel.foundDevices, id: \.id) { device in
                                        HStack {
                                            Text(device.peripheral?.name ?? "Unknown Device")
                                                .font(.system(size: 18, weight: .regular, design: .default))

                                            Spacer()

                                            if device.connected {
                                                Text("Connected")
                                                    .foregroundStyle(.green)
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 5)
                                            } else {
                                                Button("Connect") {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        viewModel.connectDevice(device)
                                                    }
                                                }
                                                .buttonStyle(.borderless)
                                                .foregroundStyle(.gray)
                                                .padding(.horizontal)
                                                .padding(.vertical, 5)
                                                .background(.gray.opacity(0.15))
                                                .clipShape(
                                                    Capsule()
                                                )
                                            }

                                            Menu {
                                                NavigationLink("Info") {
                                                    DetailView()
                                                }
                                                Button("Remove") {
                                                    print("Remove device")
                                                    viewModel.removeFoundDevice(device)
                                                }
                                            } label: {
                                                Image(systemName: "ellipsis.circle")
                                            } // MENU
                                        } //: HSTACK
                                    } //: FOR LOOP
                                } //: VSTACK
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
            } //: BUTTON
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
