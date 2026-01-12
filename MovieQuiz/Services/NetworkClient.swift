import Foundation

protocol NetworkRoutingAsync {
    func fetch(url: URL) async throws -> Data
}

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting, NetworkRoutingAsync {

    enum NetworkError: Error {
        case codeError
        case emptyData
        case badStatusCode(Int)
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          
            if let error = error {
                handler(.failure(error))
                return
            }
          
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else {
                handler(.failure(NetworkError.emptyData))
                return
            }
            handler(.success(data))
        }
        
        task.resume()
    }
    
    func fetch(url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NetworkError.badStatusCode(http.statusCode)
        }
        guard !data.isEmpty else { throw NetworkError.emptyData }
        return data
    }
}

