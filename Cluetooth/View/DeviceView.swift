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

    //MARK: - BODY
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("\(viewModel.linkedDevice?.name ?? "Unknown")")
                    .font(.title)
                    .fontWeight(.light)

                Spacer()

                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        dismiss()
                    }
            } //: HSTACK
            .padding(.top, 15)
            .padding(.horizontal, 10)
            .padding(.bottom, 0)

            ScrollView {
                VStack (alignment: .leading, spacing: 15) {
                    // Name
                    VStack (alignment: .leading, spacing: 10) {
                        Text(viewModel.linkedDevice?.name ?? "Unknown")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)

                        HStack {
                            Text("UID ")
                                .font(.title3)

                            Spacer()

                            Text(viewModel.linkedDevice?.uid.uuidString ?? "Unknown UID")
                        }
                    } //: VSTACK

                    // Adv Data
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Advertisement Data")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        if let advData = viewModel.linkedDevice?.advertisementData, advData.isEmpty {
                            Text("No advertisement data found.")
                        } else {
                            ForEach(Array(viewModel.linkedDevice?.advertisementData ?? [:]), id: \.key) { key, value in
                                HStack(alignment: .top, spacing: 10) {
                                    Text(key)
                                        .font(.subheadline)

                                    Spacer()

                                    Text(value)
                                }
                            }
                        }
                    } //: VSTACK - Advertisement Data

                    // Services + Characteristics
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Services")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)

                        ForEach(Array(viewModel.linkedDevice?.servicesData ?? []), id: \.uid) { serviceData in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(serviceData.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 4)
                                    .fontWeight(.semibold)

                                if serviceData.characteristics.isEmpty {
                                    Text("No characteristics found.")
                                        .foregroundColor(.secondary)
                                }
                                else {
                                    ForEach(Array(serviceData.characteristics), id: \.key) { characteristic in
                                        HStack(alignment: .top, spacing: 5) {
                                            Text(characteristic.key)
                                                .font(.callout)
                                                .fontWeight(.light)

                                            Spacer()

                                            Text(characteristic.value)
                                                .font(.callout)
                                                .fontWeight(.light)
                                        }
                                    }
                                }
                            }
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
