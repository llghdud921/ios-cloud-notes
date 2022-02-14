//
//  NoteDetailViewController.swift
//  CloudNotes
//
//  Created by 황제하 on 2022/02/08.
//

import UIKit

final class NoteDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let noteDetailScrollView = NoteDetailScrollView()
    var noteDataSource: CloudNotesDataSource?

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupNoteDetailScrollView()
        addObserverKeyboardNotification()
    }
    
    private func setupNavigation() {
        let seeMoreMenuButtonImage = UIImage(systemName: ImageNames.ellipsisCircleImageName)
        let rightButton = UIBarButtonItem(
          image: seeMoreMenuButtonImage,
          style: .done,
          target: nil,
          action: nil
        )
        navigationItem.setRightBarButton(rightButton, animated: false)
    }
    
    private func setupNoteDetailScrollView() {
        noteDetailScrollView.delegate = self
        view.addSubview(noteDetailScrollView)
        noteDetailScrollView.setupConstraint(view: view)
    }
    
    func setupDetailView(index: Int) {
        if let information = noteDataSource?.noteInformations?[index] {
            noteDetailScrollView.configure(with: information)
            scrollTextViewToVisible()
            view.endEditing(true)
        }
    }
    
    private func scrollTextViewToVisible() {
        DispatchQueue.main.async { [weak self] in
            if let dateLabelHeight = self?.noteDetailScrollView.lastModifiedDateLabel.frame.height {
                let offset = CGPoint(x: 0, y: dateLabelHeight)
                self?.noteDetailScrollView.setContentOffset(offset, animated: true)
            }
        }
    }
}

// MARK: - ScrollView Delegate

extension NoteDetailViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let dateLabelHeight = noteDetailScrollView.lastModifiedDateLabel.frame.height

        if scrollView.contentOffset.y < dateLabelHeight {
            targetContentOffset.pointee = CGPoint.zero
        }
    }
}

// MARK: - Keyboard

extension NoteDetailViewController {
    private func addObserverKeyboardNotification() {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(keyboardWillShow),
          name: UIResponder.keyboardWillShowNotification,
          object: nil
        )
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(keyboardWillHide),
          name: UIResponder.keyboardWillHideNotification,
          object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let info = sender.userInfo else {
            return
        }
        
        let userInfo = info as NSDictionary
        guard let keyboardFrame = userInfo.value(
          forKey: UIResponder.keyboardFrameEndUserInfoKey
        ) as? NSValue else {
            return
        }
        
        let keyboardRect = keyboardFrame.cgRectValue
        noteDetailScrollView.contentInset.bottom = keyboardRect.height
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        noteDetailScrollView.contentInset.bottom = .zero
    }
}
