//
//  ContentView.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 2/9/25.
//

import SwiftUI
import SwiftData
import UIKit

struct MainView: View {
    //MARK: - PROPERTIES
    @Query private var devices: [Device]

    @StateObject private var viewModel: MainViewModel = MainViewModel()

    @State private var isConnectButtonPressed: Bool = false
    @State private var showDeviceDetailView: Bool = false

    //MARK: - INITIALIZER
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.accentColor)]
    }

    //MARK: - FUNCTIONS
    func handleTapChevron(for device: Device) {
        if device.connected {
            showDeviceDetailView = true
        } else {
            viewModel.toggleDeviceExpanded(uuid: device.uid)
        }
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
                                ForEach(Array(viewModel.foundDevices.enumerated()), id: \.element.id) { index, device in

                                    MainViewDeviceCell(
                                        device: $viewModel.foundDevices[index],
                                        connectAction: {viewModel.connectDevice(device)},
                                        disconnectAction: {viewModel.disconnectDevice()},
                                        toggleAction: {handleTapChevron(for: device)},
                                        isConnectButtonPressed: $isConnectButtonPressed,
                                        showDeviceDetailView: $showDeviceDetailView
                                    )

                                    if device.expanded && !device.connected {
                                        VStack(alignment: .leading) {
                                            ForEach(Array(device.advertisementData.keys.sorted()), id: \.self) { serviceKey in
                                                HStack{
                                                    Text("\(serviceKey)")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.secondary)
                                                    Spacer()
                                                    Text("\(device.advertisementData[serviceKey] ?? "No value")")
                                                        .font(.caption)
                                                        .fontWeight(.light)
                                                }
                                                .padding(.vertical, 3)
                                            } //: FOR LOOP - Services
                                        } //: VSTACK
                                        .padding(5)
                                    }

                                    Divider()
//                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 3)
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
            .foregroundStyle(viewModel.isScanning ? Color.accentColor.opacity(0.5) : Color.accentColor.opacity(1))
            .font(.system(size: 25, weight: .medium, design: .default))
            .padding(.vertical, 15)
        } //: NAV
    } //: VIEW
}

//MARK: - PREVIEW
#Preview {
    MainView()
}
