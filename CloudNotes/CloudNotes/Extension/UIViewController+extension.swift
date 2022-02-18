//
//  UIViewController+extension.swift
//  CloudNotes
//
//  Created by 이호영 on 2022/02/17.
//

import UIKit

extension UIViewController {
    func showDeleteAlert(message: String, completion: (() -> Void)? = nil) {
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            completion?()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        self.present(alert, animated: true)
    }
    
    func showActionSheet(
        titles: (String, String),
        targetBarButton: UIBarButtonItem,
        sharedHandler: @escaping (UIAlertAction) -> Void,
        deleteHandler: @escaping (UIAlertAction) -> Void
    ) {
        let sharedAction = UIAlertAction(title: titles.0, style: .default, handler: sharedHandler)
        let deleteAction = UIAlertAction(title: titles.1, style: .destructive, handler: deleteHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let popover = alert.popoverPresentationController
        popover?.sourceView = self.view
        popover?.barButtonItem = targetBarButton
        
        alert.addAction(deleteAction)
        alert.addAction(sharedAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}
