//
//  LibaryAlbumViewController.swift
//  Spotify
//
//  Created by Sonu Martin on 18/08/21.
//

import UIKit

class LibaryAlbumViewController: UIViewController {
    
    var albums = [Album]()
    
    private let noAlbumsView  = ActionLabelView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,style: .grouped)
        tableView.register(SearchResultSubTitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubTitleTableViewCell.identifier)
        tableView.isHidden = true
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.backgroundColor = .green
        view.addSubview(noAlbumsView)
        setUpNoAlbumsView()
        fetchData()
        
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
//        noAlbumsView.center = view.center
//        tableView.frame = view.bounds
    }
    
    private func setUpNoAlbumsView() {
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "You have not saved any albums",
                                                                    actionTitle: "Browse"))
    }
    
    private func fetchData() {
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let album):
                        self?.albums = album
                        self?.updateUI()
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        if albums.isEmpty {
            // Show label
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        }
        else {
            // Show table
            tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    
}
extension LibaryAlbumViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
    
}

extension LibaryAlbumViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubTitleTableViewCell.identifier, for: indexPath) as? SearchResultSubTitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name, subtitle: album.artists.first?.name ?? "-" , imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
       
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode  = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

