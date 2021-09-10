//
//  DataImportable.swift
//  CloudNotes
//
//  Created by JINHONG AN on 2021/09/04.
//

import Foundation

protocol DataImportable {
    func importData<T: Decodable>(completionHandler: @escaping (T?, Error?) -> Void)
}
