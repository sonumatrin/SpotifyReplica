//
//  AlbumViewController.swift
//  Spotify
//
//  Created by Sonu Martin on 11/05/21.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let  album: Album
    
    private var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout:  UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                    widthDimension: .fractionalWidth(1.0) ,
                                                    heightDimension: .fractionalHeight(1.0)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 1,
                                                             leading: 2,
                                                             bottom: 1,
                                                             trailing: 2)
                
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(80)),
                    subitem: item,
                    count: 2
                )

                // section
                
                let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [ NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
                return section
        })
    
    init (album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.register(RecomndedCollectionViewCell.self, forCellWithReuseIdentifier: RecomndedCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let model):
                        self?.tracks = model.tracks.items
                        self?.viewModels = (model.tracks.items.compactMap({ RecommendedTrackCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "-", artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
                            
                        }))
                        
                        self?.collectionView.reloadData()
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
   
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecomndedCollectionViewCell.identifier, for: indexPath) as? RecomndedCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .red
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView ,kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let headerViewModel = PlaylistHeaderViewmodel(
            name: album.name,
            ownerName: album.artists.first?.name,
            description: "Release Date: \(String.formatedDate(string: album.release_date ))",
            artWorkURL: URL(string: album.images.first?.url ?? "")
        )
         header.configure(with: headerViewModel)
        header.delegate = self
      return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var track = tracks[indexPath.row]
        track.album = self.album
        PLaybckPresenter.shared.startPlayback(from: self, track: track)
        
    }
    
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        
        let images = album.images
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = self.album
            return track
        })
        PLaybckPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
    
    
}

