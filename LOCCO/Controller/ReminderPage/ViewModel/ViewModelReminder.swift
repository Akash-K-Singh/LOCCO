import Foundation
import Alamofire

class ViewModelReminder {
    var arraySectionData: [SectionModel] = []
    var arrayReminderData: [ReminderModel] = []

    init() {
        // Fetch data from API
        fetchDataFromAPI()
    }

    public func fetchDataFromAPI() {
        guard let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder/sudhird@zignuts.com") else {
            return
        }
        
        AF.request(url).responseDecodable(of: [ReminderModel].self) { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let reminderModels):
                // Check if the array is empty
                if reminderModels.isEmpty {
                    print("No reminders available")
                    // Handle empty response if needed
                } else {
                    // Update ViewModel data
                    self.arrayReminderData = reminderModels
                    // After updating data, recreate section data
                    self.createSectionData()
                    // Reload table view after fetching data
                    NotificationCenter.default.post(name: Notification.Name("APIDataFetched"), object: nil)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle error if needed
            }
        }
    }

    public func pushReminderToAPI(title: String?, date: Date?, completion: @escaping (Bool) -> Void) {
        guard let unwrappedDate = date,
              let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder") else {
            completion(false)
            return
        }
        
        var reminderData: [String: Any] = [
            "email": "sudhird@zignuts.com",
            "timestamp": "none"
        ]
        if let unwrappedTitle = title {
            reminderData["title"] = unwrappedTitle
        }
        reminderData["startDate"] = formatDate(unwrappedDate)
        
        AF.request(url, method: .post, parameters: reminderData, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    public func updateReminderToAPI(reminderID: String, newTitle: String?, newDate: Date?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder/\(reminderID)") else {
            completion(false)
            return
        }
        
        var updatedData: [String: Any] = [:]
        if let newTitle = newTitle {
            updatedData["title"] = newTitle
        }
        if let newDate = newDate {
            updatedData["startDate"] = formatDate(newDate)
        }
        
        AF.request(url, method: .put, parameters: updatedData, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    public func deleteReminderFromAPI(reminderID: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://n5vd2rg187.execute-api.eu-central-1.amazonaws.com/staging/reminder/\(reminderID)") else {
            completion(false)
            return
        }
        
        AF.request(url, method: .delete).response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    public func createSectionData() {
        arraySectionData.removeAll()
        let sectionRows: [Rowmodel] = arrayReminderData.map { reminderModel in
            return Rowmodel(title: reminderModel.title, Identifier: "Reminder", date: reminderModel.startDate, time: reminderModel.updatedAt, type: "ReminderCell")
        }
        arraySectionData.append(SectionModel(identifier: "Reminder", rows: sectionRows))
        print("arraySectionData0  :  \(arraySectionData)")
        print("remin1  :  \(self.arrayReminderData)")
    }
}
