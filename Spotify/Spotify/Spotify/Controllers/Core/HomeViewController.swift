//
//  ViewController.swift
//  Spotify
//
//  Created by Sonu Martin on 16/04/21.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewRleasesCellViewModel]) // 1
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel]) // 2
    case recomndedTracks(viewModels: [RecommendedTrackCellViewModel ]) // 3
    
    var title: String {
        switch self {
            case .newReleases:
                return "New Rleased Album"
            case .featuredPlaylists:
                return "Featured Playlist"
            case .recomndedTracks:
                return "Recommended"
        }
    }
    
}

class HomeViewController: UIViewController {
    
    private var newAlbums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [AudioTrack] = []
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section: sectionIndex)
        })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSetting))
        configureCollectionView()
        fetchData()
        addLongTapGesture()
        view.addSubview(spinner)
        }
       
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didTapLongGesture))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didTapLongGesture(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint), indexPath.section == 2 else {
            return
        }
        
        let model = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: model.name, message: "Would you like to add this two playlist?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: {[weak self ] _ in
            DispatchQueue.main.async {
                let vc = LibaryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(track: model, playlist: playlist) { sucess in
                        print("added to playlist: \(sucess)")
                    }
                }
                vc.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            }
        }))
        
        present(actionSheet, animated: true)
    }

    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self,
                                 forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
        collectionView.register(NewReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        view.addSubview(collectionView)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self,
                                forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        view.addSubview(collectionView)
        collectionView.register(RecomndedCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecomndedCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
    
    private func fetchData() {
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        print("Start fetching data")
        var newRelease: NewReleasesResponse?
        var featuredPlayList: FeaturedPlaylistResponse?
        var recomendation: RecomendationResponse?
        
        // New Relases
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
                case .success(let model):
                    newRelease = model
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
        
        // Featured Playlists
        
        APICaller.shared.getFeaturedPlayLists { result in
            defer {
                group.leave()
            }
            switch result {
                case .success(let model):
                    featuredPlayList = model
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
        // Recomnded tracks
        APICaller.shared.getRecommendedGenres { result in
            defer{
                group.leave()
            }
            switch result {
                case .success(let model):
                    let genres = model.genres
                    var seeds = Set<String>()
                    while seeds.count<5 {
                        if let random = genres.randomElement() {
                            seeds.insert(random)
                        }
                    }
                    
                    APICaller.shared.getRecomamendations(genres: seeds) { recommendedResult in
                        defer {
                            group.leave()
                        }
                        
                        switch recommendedResult {
                            case .success(let model):
                                recomendation = model
                            case .failure(let error):
                                print(error.localizedDescription)
                                
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        group.notify(queue: .main) {
            
            guard let newAlbums = newRelease?.albums.items,
                  let playlist = featuredPlayList?.playlists.items,
                  let tracks = recomendation?.tracks else {
                fatalError("Models are nil")
            }
            self.configureModels(
                newAlbums: newAlbums,
                playlists: playlist,
                track: tracks
            )
        }
    }
    
    private func configureModels(
        newAlbums: [Album],
        playlists: [Playlist],
        track: [AudioTrack]
        
    ) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = track
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewRleasesCellViewModel(name: $0.name,
                                       artworkURL: URL(string: $0.images.first?.url ?? ""),
                                       numberOfTracks: $0.total_tracks ?? 0,
                                       artistName: $0.artists.first?.name ?? "-")
        })))
        
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(
                name: $0.name,
                artworkURL: URL(string: $0.images?.first?.url ?? ""),
                creatorName: $0.owner.display_name)
        })))
         
        
        sections.append(.recomndedTracks(viewModels: track.compactMap({
            return RecommendedTrackCellViewModel(
                name:$0.name ,
                artistName: $0.artists.first?.name ?? "-",
                artworkURL:URL(string:  $0.album?.images.first?.url ?? ""))
        })))
        
        collectionView.reloadData()
    }
    
    @objc func didTapSetting() {
        let vc = SettingViewController()
        vc.title = "Setting"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       let type = sections[section]
        switch type {
            case .newReleases(let viewModels):
                return viewModels.count
            case .featuredPlaylists(let viewModels):
                return viewModels.count
            case .recomndedTracks(let viewModels):
                return viewModels.count
                
        }

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
         switch type {
             case .newReleases(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                      for: indexPath
                )
                as? NewReleaseCollectionViewCell else {
                    return UICollectionViewCell()
                }
                let viewModel = viewModels[indexPath.row]
                cell.configure(with: viewModel)
                return cell
                 
             case .featuredPlaylists(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
                      for: indexPath
                )
                as? FeaturedPlaylistCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: viewModels[indexPath.row])
                return cell
                 
                 
             case .recomndedTracks(let viewModels):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecomndedCollectionViewCell.identifier ,
                      for: indexPath
                )
                as? RecomndedCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(with: viewModels[indexPath.row])
                return cell
             
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
            case .newReleases(let viewModels):
                let album = newAlbums[indexPath.row ]
                let vc = AlbumViewController(album: album)
                vc.title = album.name
                vc.navigationItem.largeTitleDisplayMode = .never
                navigationController?.pushViewController(vc, animated: true)
                
            case .featuredPlaylists(let viewModels):
                let playlist = playlists[indexPath.row]
                let vc = PlaylistViewController(playlist: playlist)
                vc.title = playlist.name
                vc.navigationItem.largeTitleDisplayMode = .never
                navigationController?.pushViewController(vc, animated: true)
    
            case .recomndedTracks(let viewModels):
                let track = tracks[indexPath.row]
            
                // here Playbackpresenter class can be called directly to call the function because the function declared static
                
                PLaybckPresenter.shared.startPlayback(from: self, track: track)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader  else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        return header
    }
    
    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        
        let supplementaryView = [ NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
        
        switch section {
            case 0:
                // item
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(120)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                             leading: 2,
                                                             bottom: 2,
                                                             trailing: 2)
                
                
                // vertical group in horizontal group
                
                let verticalGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(390)),
                    subitem: item,
                    count: 3
                )
                
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.9),
                        heightDimension: .absolute(390)),
                    subitem: verticalGroup,
                    count: 1
                )

              
                // section
                
                let section = NSCollectionLayoutSection(group: horizontalGroup)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = supplementaryView
                return section
                
            case 1:
                // item
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .absolute(200) ,
                                                    heightDimension: .absolute(200)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                             leading: 2,
                                                             bottom: 2,
                                                             trailing: 2)
                
                
                let verticallGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(200),
                        heightDimension: .absolute(400)),
                    subitem: item,
                    count: 2
                )

                
                // vertical group in horizontal group
                
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(200),
                        heightDimension: .absolute(400)),
                    subitem: verticallGroup,
                    count: 1
                )

              
                // section
                
                let section = NSCollectionLayoutSection(group: horizontalGroup)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = supplementaryView
                return section
                
            case 2:
                // item
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .fractionalWidth(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                             leading: 2,
                                                             bottom: 2,
                                                             trailing: 2)
                
                
                // vertical group in horizontal group
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(80)),
                    subitem: item,
                    count: 1
                )

              
                // section
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = supplementaryView
                return section
                
                
            default:
                // item
                
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(120)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                             leading: 2,
                                                             bottom: 2,
                                                             trailing: 2)
                
                
                // vertical group in horizontal group
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(390)),
                    subitem: item,
                    count: 1
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = supplementaryView
                return section
                
        }
    }
    
}
