//
//  SearchViewController.swift
//  Spotify
//
//  Created by Sonu Martin on 16/04/21.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController, UISearchResultsUpdating,UISearchBarDelegate  {

    
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: SearchResultViewController())
        vc.searchBar.placeholder = "Songs, Artists, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
        let item =  NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                     leading: 7,
                                                     bottom: 2,
                                                     trailing: 7 )
         
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150)), subitem: item, count: 2)
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                     leading: 0,
                                                     bottom: 10,
                                                     trailing: 0)
         
        
        return NSCollectionLayoutSection(group: group )
    }))
    
    var categories = [Category]()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        self.collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        APICaller.shared.getCategorys {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let categories):
                        self?.categories = categories
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
    
    // searching string can get here
    func updateSearchResults(for searchController: UISearchController) {
     
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard
            let resultController = searchController.searchResultsController as? SearchResultViewController,
        let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        resultController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let results):
                        resultController.update(with: results)
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }


}

extension SearchViewController: SearchResultViewControllerDelegate{
    func didTapResult(_ result: SearchResult) {
        switch result {
            case .artist(let model):
                guard let url = URL(string: model.external_urls?["spotify"] ?? "") else {
                                    return
                                    }
                let vc = SFSafariViewController(url: url)
                vc.navigationItem.largeTitleDisplayMode = .never
                present(vc, animated: true)
                
            case .album(let model):
                let vc = AlbumViewController(album: model)
                vc.navigationItem.largeTitleDisplayMode = .never
                navigationController?.pushViewController(vc, animated: true)
            case .track(let track):
                PLaybckPresenter.shared.startPlayback(from: self, track: track)
                
            case .playlist(let model):
                let vc = PlaylistViewController(playlist: model)
                vc.navigationItem.largeTitleDisplayMode = .never
                navigationController?.pushViewController(vc, animated: true)
                    }
    }
    
    
    
}

extension SearchViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.row]
        cell.configure(with: CategoryCollecionViewModelCell(title: category.name, artworkURL: URL(string: category.icons.first?.url ?? "" )))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let category = categories[indexPath.row]
        let vc  = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
