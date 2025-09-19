//
//  DetailView.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 3/9/25.
//

import SwiftUI

struct DeviceView: View {
    //MARK: - PROPERTIES
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MainViewModel

    //MARK: - INITIALIZER
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    //MARK: - FUNCTIONS
    private func checkDeviceName(for device: Device) -> String {
        var resultName : String = "Unknown Name"
        guard let checkDevice = viewModel.linkedDevice else {
            return resultName
        }

        if checkDevice.name == "Unknown Name" {
            if let name = checkDevice.peripheral?.name {
                if !name.isEmpty && name != "Unknown Name" {
                    resultName = name
                }
            }
        } else {
            resultName = checkDevice.name
        }

        return resultName
    }

    //MARK: - BODY
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("\(checkDeviceName(for: viewModel.linkedDevice!))")
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundStyle(Color.accentColor)

                Spacer()

                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        dismiss()
                    }
            } //: HSTACK
            .padding(.top, 15)
            .padding(.horizontal, 10)
            .padding(.bottom, -10)

            ScrollView {
                VStack (alignment: .leading, spacing: 15) {
                    // Name
                    VStack (alignment: .leading, spacing: 10) {
                        Text("UID")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Text(viewModel.linkedDevice?.uid.uuidString ?? "Unknown UID")
                            .font(.callout)
                            .fontWeight(.light)

                    } //: VSTACK

                    Divider()

                    // Adv Data
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Advertisement Data")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 10)

                        if let advData = viewModel.linkedDevice?.advertisementData, advData.isEmpty {
                            Text("No advertisement data found.")
                        } else {
                            ForEach(Array(viewModel.linkedDevice?.advertisementData ?? [:]), id: \.key) { key, value in
                                DeviceViewItemCell(inputKey: key, inputValue: value)
                            }
                        }
                    } //: VSTACK - Advertisement Data

                    Divider()

                    // Services + Characteristics
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Services")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 5)

                        ForEach(Array(viewModel.linkedDevice?.servicesData ?? []), id: \.uid) { serviceData in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(serviceData.name)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)

                                if serviceData.characteristics.isEmpty {
                                    Text("No characteristics found.")
                                        .font(.callout)
                                        .fontWeight(.light)
                                }
                                else {
                                    ForEach(Array(serviceData.characteristics), id: \.key) { characteristic in
                                        DeviceViewItemCell(inputKey: characteristic.key, inputValue: characteristic.value)
                                    }
                                }
                            }
                            .padding(.top, 5)
                            .padding(.bottom, 10)
                        }
                    } //: VSTACK - Services
                } //: VSTACK)
                .padding(10)
            } //: SCROLLVIEW
        } //: VSTACK - Main
        .padding(.horizontal, 10)
    }
}

//MARK: - PREVIEW
#Preview {
    DeviceView(viewModel: MainViewModel())
}
