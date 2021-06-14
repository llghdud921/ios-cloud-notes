//
//  NoteDetailViewController.swift
//  CloudNotes
//
//  Created by 배은서 on 2021/06/03.
//

import UIKit

final class NoteDetailViewController: UIViewController {
    var noteTextViewModel: NoteTextViewModel?
    
    private lazy var detailNoteTextView: UITextView = {
        let textView: UITextView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        setBackGroundColor(of: textView)
        textView.contentOffset = CGPoint(x: -20, y: -20)
        textView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: nil)
        view.backgroundColor = .systemBackground
        setConstraint()
        
        noteTextViewModel?.note.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.configureTextView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        detailNoteTextView.isEditable = true
        detailNoteTextView.contentOffset = CGPoint(x: -20, y: -20)
        configureTextView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        detailNoteTextView.isEditable = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.horizontalSizeClass == .regular {
            detailNoteTextView.backgroundColor = .systemBackground
        }
        else if self.traitCollection.horizontalSizeClass == .compact {
            detailNoteTextView.backgroundColor = .systemGray3
        }
    }
    
    private func setBackGroundColor(of textView: UITextView) {
        if UITraitCollection.current.horizontalSizeClass == .compact {
            textView.backgroundColor = .systemGray3
        }
        else if UITraitCollection.current.horizontalSizeClass == .regular {
            textView.backgroundColor = .systemBackground
        }
    }
    
    private func setConstraint() {
        detailNoteTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailNoteTextView)
        
        NSLayoutConstraint.activate([
            detailNoteTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detailNoteTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            detailNoteTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailNoteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configureTextView() {
        self.detailNoteTextView.text = self.noteTextViewModel?.getTextViewData()
    }
}