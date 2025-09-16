//
//  MainViewDeviceCell.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 16/9/25.
//

import SwiftUI
import CoreBluetooth

struct MainViewDeviceCell: View {
    //MARK: - PROPERTIES
    @Binding var device: Device
    var connectAction: () -> Void
    var toggleAction: () -> Void

    @Binding var isConnectButtonPressed: Bool
    @Binding var showDeviceDetailView: Bool

    //MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 5){
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
                            connectAction()
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
                        toggleAction()
                    }
            } //: HSTACK
            .padding(.vertical, 3)
        } //: VSTACK - Main
    } //: VIEW
}

//MARK: - PREVIEW
//#Preview {
//    MainViewDeviceCell(
//        device: Device(
//            peripheral: nil,
//            advertisementData: [:],
//            services: [],
//            connected: false
//        ),
//        connectAction: {print("Connect Device")},
//        isConnectButtonPressed: .constant(false),
//        showDeviceDetailView: .constant(false)
//    )
//}
