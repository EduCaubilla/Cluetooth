//
//  DeviceViewItemCell.swift
//  Cluetooth
//
//  Created by Edu Caubilla on 17/9/25.
//

import SwiftUI

struct DeviceViewItemCell: View {
    //MARK: - PROPERTIES
    @State var inputKey: String
    @State var inputValue: String

    //MARK: - BODY
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Text(inputKey)
                .font(.callout)
                .fontWeight(.light)

            Spacer()

            Text(inputValue)
                .font(.callout)
                .fontWeight(.light)
        }
        .padding(.vertical, 2)
    }
}

//MARK: - PREVIEW
#Preview {
    DeviceViewItemCell(inputKey: "TestKey", inputValue: "TestValue")
}
