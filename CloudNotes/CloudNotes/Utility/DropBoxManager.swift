import SwiftyDropbox
import UIKit

class DropBoxManager {
    let client = DropboxClientsManager.authorizedClient
    let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    let fileNames: [String] = ["/CloudNotes.sqlite", "/CloudNotes.sqlite-shm", "/CloudNotes.sqlite-wal"]
    let scope = [
        "account_info.read",
        "account_info.write",
        "files.content.read",
        "files.content.write",
        "files.metadata.read",
        "files.metadata.write"
    ]
    
    func authorize(_ viewController: UIViewController) {
        let scopeRequest = ScopeRequest(
            scopeType: .user,
            scopes: scope,
            includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: viewController,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            },
            scopeRequest: scopeRequest
        )
    }
    
    func upload() {
        for fileName in fileNames {
            let fileURL = url.appendingPathComponent(fileName)
            client?.files.upload(path: fileName, input: fileURL)
                .response { response, error in
                    if let response = response {
                        print(response)
                    } else if let error = error {
                        print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
                }
        }
    }
}
