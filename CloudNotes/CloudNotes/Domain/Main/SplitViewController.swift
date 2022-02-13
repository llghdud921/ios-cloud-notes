import UIKit

class SplitViewController: UISplitViewController {
    private let noteListViewController = NoteListViewController()
    private let detailedNoteViewController = DetailedNoteViewController()
    private var dataSourceProvider: NoteDataSource?

    private var currentNoteIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSourceProvider = JSONDataSourceProvider()
        self.preferredDisplayMode = .oneBesideSecondary
        self.preferredSplitBehavior = .tile
        self.setViewController(noteListViewController, for: .primary)
        self.setViewController(detailedNoteViewController, for: .secondary)
        fetchNotes()

        noteListViewController.setDelegate(delegate: self)
        detailedNoteViewController.setDelegate(delegate: self)
    }

    private func fetchNotes() {
        do {
            try dataSourceProvider?.fetch()
        } catch {
            print(error.localizedDescription)
        }

        passInitialData()
    }

    private func passInitialData() {
        guard let data = dataSourceProvider?.noteList else {
            return
        }

        noteListViewController.setNoteListData(data)
        detailedNoteViewController.setNoteData(data.first)
        self.currentNoteIndex = 0
    }
}

// MARK: - Note Data Source Delegate

extension SplitViewController: NoteListViewDelegate, DetailedNoteViewDelegate {
    func passNote(index: Int) {
        self.currentNoteIndex = index
        detailedNoteViewController.setNoteData(dataSourceProvider?.noteList[index])
    }

    func passModifiedNote(note: Note) {
        guard let index = self.currentNoteIndex else {
            return
        }

        noteListViewController.setNoteData(note, index: index)
    }
}
