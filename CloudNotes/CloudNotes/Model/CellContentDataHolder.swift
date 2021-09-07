//
//  d.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/06.
//

import UIKit

class CellContentDataHolder {
    var titleLabelText: String?
    var dateLabelText: String?
    var bodyLabelText: String?
    var dateText: String?
    var accessoryType: UITableViewCell.AccessoryType
    
    init(title: String?, date: String?, body: String?, accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator) {
        self.titleLabelText = title
        self.dateLabelText = date
        self.bodyLabelText = body
        self.accessoryType = accessoryType
    }
}
