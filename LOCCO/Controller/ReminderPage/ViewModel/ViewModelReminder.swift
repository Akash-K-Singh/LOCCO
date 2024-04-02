import Foundation

class ViewModelReminder {
    var arraySectionData: [SectionModel] = []
    var arrayReminderData: [ReminderModel] = []

    init() {
        // Fetch data from API
        fetchRemindersFromAPI()
    }

    public func fetchRemindersFromAPI() {
        guard let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder/sudhird@zignuts.com") else {
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                // Handle error if needed
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                var reminderModels = try decoder.decode([ReminderModel].self, from: data)
                
                // Sort the array based on startDate field
                reminderModels.sort { $0.startDate < $1.startDate }
                
                // Update ViewModel data
                self.arrayReminderData = reminderModels
                
                // After updating data, recreate section data
                self.createSectionData()
                
                // Reload table view after fetching data
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("APIDataFetched"), object: nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                // Handle decoding error if needed
            }
        }.resume()
    }

    public func pushReminderToAPI(title: String?, date: Date?, completion: @escaping (Bool) -> Void) {
        // Define your API endpoint URL
        guard let unwrappedDate = date,
              let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder") else {
            // If the date is nil or the URL cannot be constructed, call the completion handler with false and return
            completion(false)
            return
        }
        
        // Prepare reminder data
        var reminderData: [String: Any] = [
            "email": "sudhird@zignuts.com",// Adding email parameter
            "description": "",
            "endDate": "",
            
        ]
        if let unwrappedTitle = title {
            // If the title is not nil, add it to the reminder data
            reminderData["title"] = unwrappedTitle
        }
        // Add the date as a Unix timestamp to the reminder data
        reminderData["startDate"] = formatDate(unwrappedDate) // Adding startDate parameter
        
        // Create JSON data from reminderData
        guard let jsonData = try? JSONSerialization.data(withJSONObject: reminderData) else {
            // If JSON serialization fails, call the completion handler with false and return
            completion(false)
            return
        }
        
        // Create and configure the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // If there is an error during the request, print the error and call the completion handler with false
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // If the response is not an HTTPURLResponse, call the completion handler with false
                completion(false)
                return
            }
            
            // Check the HTTP status code for success
            if 200 ..< 300 ~= httpResponse.statusCode {
                // If the status code indicates success, call the completion handler with true
                completion(true)
            } else {
                // If the status code indicates failure, print the status code and call the completion handler with false
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(false)
            }
        }.resume() // Start the data task
    }

    public func deleteReminderFromAPI(id: String, completion: @escaping (Bool) -> Void) {
        // Construct the URL with the provided id
        guard let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder/id/\(id)") else {
            // If the URL cannot be constructed, call the completion handler with false and return
            completion(false)
            return
        }
       
        // Create and configure the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        // Perform the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // If there is an error during the request, print the error and call the completion handler with false
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // If the response is not an HTTPURLResponse, call the completion handler with false
                completion(false)
                return
            }
            
            // Check the HTTP status code for success
            if 200 ..< 300 ~= httpResponse.statusCode {
                // If the status code indicates success, call the completion handler with true
                completion(true)
            } else {
                // If the status code indicates failure, print the status code and call the completion handler with false
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(false)
            }
        }.resume() // Start the data task
    }

    public func putReminderToAPI(id: String, title: String, date: Date, completion: @escaping (Bool) -> Void) {
        // Construct the URL with the provided id
        guard let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder/id/\(id)") else {
            // If the URL cannot be constructed, call the completion handler with false and return
            completion(false)
            return
        }
        
        // Create and configure the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let formattedDate = formatDate(date)
        
        // Create a dictionary representing the updated data
        let updatedData: [String: Any] = [
            "id": id,
            "email": "sudhird@zignuts.com",
            "title": title,
            "description": "",
            "startDate": formattedDate,
            "endDate": "" // Assuming startDate and endDate are the same
        ]
        
        // Convert the dictionary to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updatedData, options: [])
        } catch {
            // If there is an error converting the data to JSON, print the error and call the completion handler with false
            print("Error encoding JSON: \(error.localizedDescription)")
            completion(false)
            return
        }

        // Set the content type header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // If there is an error during the request, print the error and call the completion handler with false
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // If the response is not an HTTPURLResponse, call the completion handler with false
                completion(false)
                return
            }
            
            // Check the HTTP status code for success
            if 200 ..< 300 ~= httpResponse.statusCode {
                // If the status code indicates success, call the completion handler with true
                completion(true)
            } else {
                // If the status code indicates failure, print the status code and call the completion handler with false
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(false)
            }
        }.resume() // Start the data task
    }
    
    // Function to format date into "yyyy-MM-dd" format
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: date)
    }

    public func createSectionData() {
        // This method remains the same as before, as it's used to structure your ViewModel's data
        arraySectionData.removeAll()
        // Header Model
        let sectionRows: [Rowmodel] = arrayReminderData.map { reminderModel in
            return Rowmodel(title: reminderModel.title, Identifier: reminderModel.id, date: reminderModel.startDate, time: reminderModel.createdAt, type: "ReminderCell")
        }
        arraySectionData.append(SectionModel(identifier: "Reminder", rows: sectionRows))
    }
}
