//
//  ActorDetailsViewController.swift
//  Lab
//
//  Created by Roberto Evangelista da Silva Filho on 14/12/2018.
//  Copyright © 2018 Roberto Evangelista da Silva Filho. All rights reserved.
//

import UIKit

class ActorDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var birthplaceLabel: UILabel!
    @IBOutlet weak var pictureLabel: UILabel!
    @IBOutlet weak var biographyLabel: UITextView!
    
//    let apiURL = "https://api.themoviedb.org/3"
//    let apiKey = "0424fa87b82e17923e0bf89b143c6fb2"
    let networkHelper = NetworkHelper()
    
    var selectedActor: Actor?
    var fullActor: Actor? {
        didSet {
            nameLabel.text = fullActor?.name
            birthdayLabel.text = fullActor?.birthday
            birthplaceLabel.text = fullActor?.birthplace
            pictureLabel.text = fullActor?.picture
            biographyLabel.text = fullActor?.biography
        }
    }
    var searchMovies: [Movie]? {
        didSet {
            searchMovieDetailRequest()
        }
    }
    var fullMovie: [Movie]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchActorDetailsRequest()
        searchMoviesRequest()
        
    }
    
    func searchActorDetailsRequest() {
        guard let actor = selectedActor else {
            print("Não recebi nenhum ator dessa segue")
            return
        }
        let searchRequest = "/person/\(actor.id)"
        let myQueryItems = [
            "api_key": networkHelper.apiKey
            ]
        var urlComponents = URLComponents(string: networkHelper.apiURL + searchRequest)
        urlComponents?.queryItems = networkHelper.queryItems(dictionary: myQueryItems)
        
        let task = URLSession.shared.dataTask(with: urlComponents!.url!) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print("error")
                return
            }
            do {
                let decode = try JSONDecoder().decode(Actor.self, from: dataResponse)
                DispatchQueue.main.async {
                    self.fullActor = decode
                }
            } catch let parsinError{
                print("Error", parsinError)
            }
        }
        task.resume()
    }
    
    func searchMoviesRequest() {
        guard let actor = selectedActor else {
            print("Não recebi nenhum ator dessa segue")
            return
        }
        let searchRequest = "/person/\(actor.id)/movie_credits"
        let myQueryItems = [
            "api_key": networkHelper.apiKey
        ]
        var urlComponents = URLComponents(string: networkHelper.apiURL + searchRequest)
        urlComponents?.queryItems = networkHelper.queryItems(dictionary: myQueryItems)
        
        let task = URLSession.shared.dataTask(with: urlComponents!.url!) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print("error")
                return
            }
            do {
                let decode = try JSONDecoder().decode(MovieSearchResponse.self, from: dataResponse)
                DispatchQueue.main.async {
                    self.searchMovies = decode.cast
                }
            } catch let parsinError{
                print("Error", parsinError)
            }
        }
        task.resume()
    }
    
    func searchMovieDetailRequest() {
        guard let movies = searchMovies else { return }
        for movie in movies {
            let searchRequest = "/movie/\(movie.id)"
            let myQueryItems = [
                "api_key": networkHelper.apiKey
            ]
            var urlComponents = URLComponents(string: networkHelper.apiURL + searchRequest)
            urlComponents?.queryItems = networkHelper.queryItems(dictionary: myQueryItems)
            
            let task = URLSession.shared.dataTask(with: urlComponents!.url!) { (data, response, error) in
                guard let dataResponse = data, error == nil else {
                    print("error")
                    return
                }
                do {
                    let decode = try JSONDecoder().decode(Movie.self, from: dataResponse)
                    DispatchQueue.main.async {
                        self.fullMovie?.append(decode)
                        print(decode)
                    }
                } catch let parsinError{
                    print("Error", parsinError)
                }
            }
            task.resume()
        }
    }
    
}
