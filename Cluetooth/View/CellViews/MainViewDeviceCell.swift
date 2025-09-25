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
    var disconnectAction: () -> Void
    var toggleAction: () -> Void

    @Binding var isConnectButtonPressed: Bool
    @Binding var showDeviceDetailView: Bool

    @State var isPressed: Bool = false

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
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.secondary.opacity(0.5))
                        .padding(.horizontal, 2)
                        .onTapGesture {
                            disconnectAction()
                        }

                    Text("Connecting")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundStyle(.orange)
                        .padding(.vertical, 3)

                    ProgressView()
                        .padding(.horizontal, 2)
                        .accessibilityIdentifier("Progress View")

                } else if device.connected {
                    Text("Connected")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundStyle(.green)
                        .padding(.vertical, 3)
                        .padding(.trailing, 5)

                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.secondary.opacity(0.5))
                        .padding(.trailing, 2)
                        .onTapGesture {
                            disconnectAction()
                        }
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
                    .gesture(
                        LongPressGesture(minimumDuration: 0)
                            .onChanged { _ in
                                self.isPressed = true
                            }
                            .onEnded { _ in
                                self.isPressed = false
                            }
                    )
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
                    .background(self.isPressed ? .gray.opacity(0.1) : .gray.opacity(0.2))
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

#if DEBUG
//MARK: - PREVIEW
//#Preview {
//    MainViewDeviceCell(
//        device: Device(
//            peripheral: nil,
//            advertisementData: [:],
//            services: [],
//            connected: false
//        ),
//        connectAction: {},
//        isConnectButtonPressed: .constant(false),
//        showDeviceDetailView: .constant(false)
//    )
//}
#endif
