//
//  LibaryViewController.swift
//  Spotify
//
//  Created by Sonu Martin on 16/04/21.
//

import UIKit

class LibaryViewController: UIViewController {
    
    private let playlistsVC = LibaryPlaylistsViewController()
    private let albumsVC = LibaryAlbumViewController()
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        return scrollView
    }()
    
    private let toggleView = LibaryToggleView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        view.addSubview(toggleView)
        view.addSubview(scrollView)
        
        toggleView.delegate = self
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: view.width * 2, height: scrollView.height)
        addChildren()
        updateBarButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 55, width: view.width, height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 55)
        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
    }
    
    private func updateBarButtons() {
        switch toggleView.state{
            case .playlist:
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
            default:
                navigationItem.rightBarButtonItem = nil
                
        }
    }
    
    @objc private func didTapAdd() {
         playlistsVC.showCreatePlaylistAlert()
     }
    
    private func addChildren() {
        addChild(playlistsVC)
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistsVC.didMove(toParent: self)
        
        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVC.didMove(toParent: self)
    }

}

extension LibaryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width - 100) {
            toggleView.update(for: .album)
            updateBarButtons()
        } else {
            toggleView.update(for: .playlist)
            updateBarButtons()
        }
    }
}

extension LibaryViewController: LibaryToggleViewDelegate {
    func libaryToggleViewDidTapPlalists(_ toggleView: LibaryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }
    
    func libaryToggleViewDidTapAlbums(_ toggleView: LibaryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
    
    
}
