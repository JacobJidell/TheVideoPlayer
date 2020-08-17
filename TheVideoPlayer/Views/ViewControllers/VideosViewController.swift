//
//  VideosViewController.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-17.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import UIKit

class VideosViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var videos: [Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchVideos()
    }

    private func fetchVideos() {
        do {
            self.videos = try VideoManager.fetchVideos()
            self.tableView.reloadData()
        } catch {
            print("Could not fetch videos. Error: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource

extension VideosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let video = videos[safe: indexPath.row] else { return UITableViewCell() }

        let cell = UITableViewCell()
        cell.textLabel?.text = video.title
        cell.detailTextLabel?.text = "\(video.videoDescription) \n\n \(video.subtitle)"
        return cell
    }
}

// MARK: - UITableViewDelegate

extension VideosViewController: UITableViewDelegate {

}
