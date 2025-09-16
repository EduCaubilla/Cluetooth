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

    @StateObject private var viewModel: MainViewModel = MainViewModel()

    @State private var isConnectButtonPressed: Bool = false
    @State private var showDeviceDetailView: Bool = false

    //MARK: - INITIALIZER
    init() {
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
                                    DeviceView(viewModel: viewModel)
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
                                            .padding(.vertical, 5)

                                        Text(device.peripheral?.name ?? "Unknown Device")
                                            .font(.system(size: 18, weight: .regular, design: .default))

                                        Spacer()

                                        if device.connecting {
                                            Text("Connecting")
                                                .font(.system(size: 17, weight: .regular, design: .default))
                                                .foregroundStyle(.orange)
                                                .padding(.vertical, 3)

                                            ProgressView()
                                                .padding(.horizontal, 2)

                                        } else if device.connected {
                                            Text("Connected")
                                                .font(.system(size: 17, weight: .regular, design: .default))
                                                .foregroundStyle(.green)
                                                .padding(.vertical, 3)
                                                .padding(.trailing, 5)

                                        } else {
                                            Button("Connect") {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    viewModel.connectDevice(device)
                                                    isConnectButtonPressed = true
                                                }

                                            }
                                            .padding(.vertical, 3)
                                            .padding(.horizontal)
                                            .font(.system(size: 18, weight: .regular, design: .default))
                                            .buttonStyle(.borderless)
                                            .foregroundStyle(.gray)
                                            .background(isConnectButtonPressed ? .gray.opacity(0.1) : .gray.opacity(0.12))
                                            .clipShape(
                                                Capsule()
                                            )
                                        }

                                        Image(systemName: device.expanded ? "chevron.down" : "chevron.right")
                                            .onTapGesture {
                                                if device.connected {
                                                    showDeviceDetailView = true
                                                } else {
                                                    device.expanded = !device.expanded
                                                }
                                            }
                                    } //: HSTACK

                                    if device.expanded && !device.connected {
                                        VStack(alignment: .leading) {
                                            ForEach(Array(device.advertisementData.keys.sorted()), id: \.self) { serviceKey in
                                                HStack{
                                                    Text("\(serviceKey)")
                                                        .font(.system(size: 15, weight: .regular, design: .default))
                                                    Spacer()
                                                    Text("\(device.advertisementData[serviceKey] ?? "No value")")
                                                      .font(.system(size: 15, weight: .regular, design: .default))
                                                }
                                                .padding(.bottom, 3)
                                            } //: FOR LOOP - Services
                                        } //: VSTACK
                                        .padding(.leading, 5)
                                    }
                                } //: FOR LOOP - Devices
                            } //: VSTACK
                            .fullScreenCover(isPresented: $showDeviceDetailView) {
                                DeviceView(viewModel: .init())
                            }
                        } //: HSTACK - Main
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
