//
//  FeaturedFeedViewController.swift
//  ReclipFeaturedFeed
//

import UIKit
import Combine

final class FeaturedFeedViewController: UIViewController {

    private lazy var progressBar = ProgressBar()
    private let loadingCard = LoadingViewCard()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.isPagingEnabled = true
        return tableView
    }()
    
    private var viewModel: FeaturedFeedViewModel = FeaturedFeedViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoadingCard()
        viewModel.fetchVideos()
    }

    override func loadView() {
        // Note: Using OutOfBoundsTouchView here allows lower half
        // of `progressBar` to receive touches.
        view = OutOfBoundsTouchView()
        view.backgroundColor = .dark
    }

    private func showLoadingCard() {
        loadingCard.isHidden = false
    }
    
    private func hideLoadingCard() {
        loadingCard.isHidden = true
    }
    
    private func setProgressBarHidden(_ hidden: Bool) {
        switch hidden {
        case false:
            progressBar = ProgressBar()
            view.addSubview(progressBar)
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                progressBar.progressBarBottomAnchor.constraint(equalTo: view.bottomAnchor),
                progressBar.heightAnchor.constraint(equalToConstant: 44)
            ])
        case true:
            progressBar.removeFromSuperview()
        }
    }

    private func setChild(_ child: UIViewController?) {
        children.first?.willMove(toParent: nil)
        children.first?.view.removeFromSuperview()
        children.first?.removeFromParent()

        if let child = child {
            addChild(child)
            view.addSubview(child.view)
            child.view.fillSuperview()
            child.didMove(toParent: self)
        }
    }
    
    private func initView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        tableView.register(VideoFeedCell.self, forCellReuseIdentifier: "videoCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(loadingCard)
        loadingCard.centerInSuperview()
        loadingCard.isHidden = true
    }
    
    private func bindViewModel() {
        viewModel.$items
            .receive(on: RunLoop.main)
            .sink { [weak self]_ in
                self?.hideLoadingCard()
                self?.loadVideos()
            }
            .store(in: &cancellables)
    }
    
    private func loadVideos() {
        self.tableView.reloadData()
        if viewModel.items.count > 0 {
            setProgressBarHidden(false)
        }
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension FeaturedFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let videoCell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as? VideoFeedCell {
            videoCell.model = viewModel.items[indexPath.row]
            return videoCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let endDisplayingCell = cell as? VideoFeedCell {
            endDisplayingCell.videoPlayerView.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let displayingCell = cell as? VideoFeedCell {
            progressBar.setProgress(displayingCell.videoPlayerView.savedPlaybackProgress())
            
            displayingCell.videoPlayerView.$playbackProgress
                .receive(on: RunLoop.main)
                .sink { [weak self] progress in
                    self?.progressBar.setProgress(progress)
                }
                .store(in: &cancellables)
            
            progressBar.onPan = { progress in
                DispatchQueue.main.async {
                    displayingCell.videoPlayerView.setPlaybackProgress(progress)
                }
            }
        }
    }
}
