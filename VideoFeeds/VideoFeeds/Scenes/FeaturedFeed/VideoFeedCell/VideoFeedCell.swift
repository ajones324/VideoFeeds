//
//  VideoFeedCell.swift
//  ReclipFeaturedFeed
//

import UIKit
import AVKit
import AVFoundation

class VideoFeedCell: UITableViewCell {
    var model : FeedItem? {
        didSet {
            videoNameLabel.text = model?.video.videoTitle
            
            guard let urlString = model?.video.videoUrl,
                  let videoUrl = URL(string: urlString) else {
                return
            }
            videoPlayerView.url = videoUrl
            
            guard let timeAgoText = model?.video.createdAt.timeAgoDisplay() else { return }
            guard let username = model?.video.username else { return }
            descriptionLabel.text = "\(timeAgoText) from @\(username)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    let gradientBgView: VerticalGradientView = {
        let color1 = VerticalGradientView.ColorAndLocation(color: UIColor.fromHex(red: 0xf5, green: 0x6e, blue: 0x9b), location: NSNumber(floatLiteral: 1.0))
        
        let color2 = VerticalGradientView.ColorAndLocation(color: UIColor.fromHex(red: 0xec, green: 0xaf, blue: 0xed), location: NSNumber(floatLiteral: 0.0))

        let view = VerticalGradientView(colors: [color1, color2])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let videoPlayerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let videoNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .reclipBold(ofSize: 16)
        label.textColor = .bright
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .reclipRegular(ofSize: 14)
        label.textColor = .bright
        return label
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [videoNameLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        backgroundColor = .white
        addSubview(gradientBgView)
        addSubview(videoPlayerView)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            gradientBgView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0),
            gradientBgView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0),
            gradientBgView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            gradientBgView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            videoPlayerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0),
            videoPlayerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0),
            videoPlayerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            videoPlayerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        let videoTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapVideoPlayer(_:)))
        addGestureRecognizer(videoTapGesture)
    }
    
    @objc func tapVideoPlayer(_ sender: UITapGestureRecognizer) {
        videoPlayerView.togglePlayback()
    }
}
