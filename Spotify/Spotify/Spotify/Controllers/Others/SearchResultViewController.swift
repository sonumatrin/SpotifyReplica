//
//  SearchResultViewController.swift
//  Spotify
//
//  Created by Sonu Martin on 10/06/21.
//

import UIKit

struct SearchSection {
    let title: String
    let results: [SearchResult]
}
// this protocol is for when clicing cell dispaly the vc other wise o click occured

protocol SearchResultViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    weak var delegate: SearchResultViewControllerDelegate?
    
    private var sections: [SearchSection] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultDefaultTableViewCell.self,
                           forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.register(SearchResultSubTitleTableViewCell.self,
                           forCellReuseIdentifier: SearchResultSubTitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update (with results: [SearchResult]) {
        let artists = results.filter({
            switch $0 {
                case .artist: return true
                default: return false
            }
            
        })
        print(artists)
        let albums = results.filter({
            switch $0 {
                case .album: return true
                default: return false
            }
            
        })
        let tracks = results.filter({
            switch $0 {
                case .track: return true
                default: return false
            }
            
        })
        let playlists = results.filter({
            switch $0 {
                case .playlist: return true
                default: return false
            }
            
        })
        self.sections =
            [SearchSection(title: "Songs", results: tracks),
            SearchSection(title: "Artists", results: artists),
            SearchSection(title: "Playlists", results: playlists),
            SearchSection(title: "Albums", results: albums)]
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row ]

        switch result {
            case .artist(let artist):
                
                //here tableviewcell is assigned for artist
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier,
                                                               for: indexPath
                ) as? SearchResultDefaultTableViewCell else {
                    return UITableViewCell()
                }
                
                let viewModel = SearchResultDefaultTableviewCellViewModel(title: artist.name, imageURL: URL(string: artist.images?.first?.url ?? ""))
                cell.configure(with: viewModel )
                return cell
                
            case .album(let album):
                guard let Acell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubTitleTableViewCell.identifier,
                                                               for: indexPath
                ) as? SearchResultSubTitleTableViewCell else {
                    return UITableViewCell()
                }

                let viewModel = SearchResultSubtitleTableViewCellViewModel(title: album.name,subtitle:  album.artists.first?.name ?? "", imageURL: URL(string: album.images.first?.url ?? ""))
                Acell.configure(with: viewModel )
                return Acell
                
            case .track(let track):
                guard let Acell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubTitleTableViewCell.identifier,
                                                               for: indexPath
                ) as? SearchResultSubTitleTableViewCell else {
                    return UITableViewCell()
                }
                let viewModel = SearchResultSubtitleTableViewCellViewModel(title: track.name,
                                                                                 subtitle: track.artists.first?.name ?? "",
                                                                                 imageURL: URL(string: track.album?.images.first?.url ?? ""))
                               Acell.configure(with: viewModel)
                               return Acell

            case .playlist(let playlist):
                guard let Acell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubTitleTableViewCell.identifier, for: indexPath) as? SearchResultSubTitleTableViewCell else {
                    return UITableViewCell()
                }
                let viewModel = SearchResultSubtitleTableViewCellViewModel(title: playlist.name, subtitle: playlist.owner.display_name, imageURL: URL(string: playlist.images?.first?.url ?? ""))
                Acell.configure(with: viewModel)
                return Acell
                    }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = sections[indexPath.section].results[indexPath.row ]
        
        delegate?.didTapResult(result)
    }
    
    
}
