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
                if(viewModel.savedDevices.isEmpty) {
                    EmptyView()
                } else {
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
                }

                Section {
                    if viewModel.foundDevices.isEmpty {
                        Text("No devices")
                            .foregroundStyle(.gray)
                    } else {
                        HStack {
                            VStack(alignment: .leading) {
                                ForEach(viewModel.foundDevices, id: \.id) { device in
                                    HStack {
                                        Text(String(device.rssi))
                                            .font(.system(size: 16, weight: .regular, design: .default))
                                            .foregroundStyle(device.signalStrengthColor)
                                            .padding(.trailing, 3)

                                        Text(device.peripheral?.name ?? "Unknown Device")
                                            .font(.system(size: 18, weight: .regular, design: .default))

                                        Spacer()

                                        if device.connected {
                                            Text("Connected")
                                                .font(.system(size: 18, weight: .regular, design: .default))
                                                .foregroundStyle(.green)
                                                .padding(.vertical, 3)
                                        } else {
                                            Button("Connect") {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    viewModel.connectDevice(device)
                                                }
                                            }
                                            .font(.system(size: 18, weight: .regular, design: .default))
                                            .buttonStyle(.borderless)
                                            .foregroundStyle(.gray)
                                            .padding(.vertical, 3)
                                            .background(.gray.opacity(0.05))
                                            .clipShape(
                                                Capsule()
                                            )
                                        }

                                        Image(systemName: device.expanded ? "chevron.down" : "chevron.right")
                                            .onTapGesture {
                                                device.expanded = !device.expanded
                                            }
                                    } //: HSTACK

                                    if device.expanded {
                                        VStack(alignment: .leading) {
                                            Text("\(device.name)")
                                                .font(.system(size: 14, weight: .medium, design: .default))
//
                                            ForEach(Array(device.services.keys.sorted()), id: \.self) { serviceKey in
                                                HStack{
                                                    Text("\(serviceKey)")
                                                        .font(.system(size: 14, weight: .regular, design: .default))
                                                    Spacer()
                                                    Text("\(device.services[serviceKey] ?? "No value")")
                                                      .font(.system(size: 14, weight: .regular, design: .default))
                                                }
                                            } //: FOR LOOP - Services
                                        } //: VSTACK
                                    }
                                } //: FOR LOOP - Devices
                            } //: VSTACK
                        }
                    }
                } header: {
                    HStack {
                        Text("Devices")

                        if viewModel.isScanning {
                            ProgressView()
                                .padding(.leading, 5)
                        }
                    }
                } footer: {
                    EmptyView()
                } //: SECTION
            } //: LIST
            .listStyle(.grouped)
            .navigationTitle(Text("Cluetooth"))
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top, -15)

            Button("Scan for devices") {
                Task {
                    if !viewModel.isScanning {
                        await viewModel.fetchDevices()
                    }
                }
            } //: BUTTON
            .foregroundStyle(viewModel.isScanning ? .blue.opacity(0.5) : .blue)
            .font(.system(size: 25, weight: .medium, design: .default))
            .padding(.vertical, 15)
        } //: NAV
    } //: VIEW
}

//MARK: - PREVIEW
#Preview {
    MainView()
}
