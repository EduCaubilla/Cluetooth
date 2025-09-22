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
    @ObservedObject private var viewModel: MainViewModel = MainViewModel()

    @State private var isConnectButtonPressed: Bool = false
    @State private var showDeviceDetailView: Bool = false
    @State private var scanTapped: Bool = false

    //MARK: - INITIALIZER
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.accentColor)]
    }

    //MARK: - FUNCTIONS
    func handleTapChevron(for device: Device) {
        if device.connected {
            showDeviceDetailView = true
            device.expanded = false
        } else {
            viewModel.toggleDeviceExpanded(uuid: device.uid)
        }
    }

    func scanDevices() {
        Task {
            if !viewModel.isScanning {
                await viewModel.fetchDevices()
            }
        }
    }

    //MARK: - BODY
    var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .top, spacing: 15) {
                    Text("Devices nearby")
                        .padding(.leading, 20)
                        .foregroundStyle(.secondary)
                        .font(.title2)
                        .fontWeight(.light)

                    if viewModel.isScanning {
                        ProgressView()
                            .padding(.top, 10)
                    }

                    Spacer()

                    if !viewModel.foundDevices.isEmpty {
                        Button(action: {
                            viewModel.restartScan()
                        }) {
                            Label("Reset list", systemImage: "arrow.trianglehead.2.clockwise")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.secondary)
                        .padding(EdgeInsets(top: 7, leading: 0, bottom: 0, trailing: 20))
                    }
                }
                .padding(.bottom, 10)

                List {
                    if viewModel.foundDevices.isEmpty {
                        EmptyView()
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
                                        .padding(.vertical, 3)
                                } //: FOR LOOP - Devices
                            } //: VSTACK
                            .fullScreenCover(isPresented: $showDeviceDetailView) {
                                DeviceView(viewModel: viewModel)
                            }
                        } //: HSTACK - Main
                    }
                } //: LIST
                .refreshable {
                    scanDevices()
                }
                .padding(.top, -12)
                .listStyle(.inset)
                .navigationTitle(Text("Cluetooth"))
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .safeAreaInset(edge: .bottom, alignment: .center, spacing: 20) {
                    Button {
                        scanDevices()
                    } label: {
                        Text("Scan for devices")
                            .font(.title3)
                            .fontWeight(.regular)
                            .foregroundStyle(viewModel.isScanning ? Color.accentColor.opacity(0.5) : Color.accentColor.opacity(1))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 60)
                            .background(viewModel.isScanning ? Color.ctGray.opacity(0.5) : Color.ctGray.opacity(1))
                    }
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2.0, y: 2.0)
                    .padding(20)
                }
                .alert(isPresented: $viewModel.showConnectionTimedOutAlert) {
                    Alert(title: Text("Connection Timed Out"), message: Text("The device couldn't be connected. You may get closer or make sure it is turned on and try again."), dismissButton: .default(Text("Ok")))
                }
            }
        } //: NAV
    } //: VIEW
}

//MARK: - PREVIEW
#Preview {
    MainView()
}
