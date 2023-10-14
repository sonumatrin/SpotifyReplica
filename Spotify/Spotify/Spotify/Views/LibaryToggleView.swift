//
//  LibaryToggleView.swift
//  Spotify
//
//  Created by Sonu Martin on 19/08/21.
//

import UIKit

protocol LibaryToggleViewDelegate: AnyObject {
    func libaryToggleViewDidTapPlalists(_ toggleView: LibaryToggleView)
    func libaryToggleViewDidTapAlbums(_ toggleView: LibaryToggleView)
}
class LibaryToggleView: UIView {
    
    enum State {
        case playlist
        case album
    }
    
    var state: State = .playlist
    
    weak var delegate: LibaryToggleViewDelegate?
    
    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Albums", for: .normal)
        button.setTitleColor(.label, for: .normal)
        
        return button
    }()
    
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
    }
    
     func layoutIndicator() {
        switch state {
            case .playlist:
                indicatorView.frame = CGRect(x: 0, y: playlistButton.bottom, width: 100, height: 3)
            case.album:
                indicatorView.frame = CGRect(x: 100, y: playlistButton.bottom, width: 100, height: 3)
            
        }
    }
    
    @objc private func didTapPlaylists() {
        state = .playlist
        delegate?.libaryToggleViewDidTapPlalists(self)
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
    
    @objc private func didTapAlbums() {
        state = .album
        delegate?.libaryToggleViewDidTapAlbums(self)
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
    
    func update(for state: State) {
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
}
