//
//  HomeView.swift
//  ServerChecker
//
//  Created by Kyle Kim on 2022/12/28.
//

import SwiftUI
import Combine

enum AutoUpdateState {
    case on
    case off
    
    var imageName: String {
        switch self {
        case .on:
            return "stop.fill"
        case .off:
            return "play.fill"
        }
    }
    
    var imageColor : Color {
        switch self {
        case .on:
            return .red
        case .off:
            return .green
        }
    }
    
    mutating func switchState() {
        switch self {
        case .on:
            self = .off
        case .off:
            self = .on
        }
    }
}

struct HomeView: View {
    @State private var nameText : String = ""
    @State private var serverText : String = ""
    @State private var showAlert : Bool = false
    @State private var showStopAlert : Bool = false
    
    @State private var hideModifyView : Bool = true
    
    @State private var autoUpdateState : AutoUpdateState = .on
//    @State private var timerCount : String = "5"
    @StateObject var viewModel = ViewModel()
    @State var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            VStack{
                Text("Server Checker")
                    .font(.title)
                    .padding(.top, 20)
                HStack{
                    Spacer()
                    Text("TimerInterval: ")
                    TextField("Default 5sec", text: self.$viewModel.timerCount)
                        .frame(width: 100, height: 40, alignment: .center)
                        .onChange(of: self.viewModel.timerCount, perform: { newValue in
                            self.viewModel.timerIntervalTextPublisher.send(newValue)
                        })
                        .onReceive(self.viewModel.timerIntervalTextPublisher.debounce(for: .seconds(3), scheduler: DispatchQueue.main), perform: { text in
                            switch self.autoUpdateState {
                            case .on:
                                self.timer = Timer.publish(every: self.viewModel.timerCount.convertToTimeInterval(), on: .main, in: .common).autoconnect()
                            case .off:
                                break
                            }
                        })
                    Button(action: {
                        self.autoUpdateState.switchState()
                        switch self.autoUpdateState {
                        case .on:
                            self.viewModel.setTimeInterval()
                            self.timer = Timer.publish(every: self.viewModel.timerCount.convertToTimeInterval(), on: .main, in: .common).autoconnect()
                        case .off:
                            self.stopAction()
                        }
                    }){
                        Image(systemName: self.autoUpdateState.imageName)
                            .foregroundColor(self.autoUpdateState.imageColor)
                    }
                }
                .padding(.trailing, 20)
                .alert("Checking servers is stopped.", isPresented: $showStopAlert) {
                    Button("OK", role: .cancel) {
                        self.showStopAlert = false
                    }
                }
                HStack{
                    TextField("Type Name", text: $nameText)
                        .frame(height: 40, alignment: .center)
                    TextField("Type Server(URL)", text: $serverText)
                        .frame(height: 40, alignment: .center)
                    Button(action: {
                        self.addButtonClicked()
                    }){
                        Text("Add")
                    }
                }
                .frame(height: 40, alignment: .center)
                .padding(.horizontal, 20)
                .onReceive(self.timer) { time in
                    debugPrint("now update")
                    switch self.autoUpdateState {
                    case .on:
                        self.viewModel.updateServer()
                    case .off:
                        break
                    }
                }
                VStack{
                    List{
                        HStack(alignment: .center, spacing: 0){
                            Text("Status")
                            Text("Name")
                                .padding(.leading, 10)
                            Spacer()
                            Text("URL")
                                .padding(.trailing, 100)
                            Spacer()
                        }
                        ForEach(self.viewModel.servers.indices, id: \.self) { index in
                            HStack{
                                Circle()
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(self.viewModel.servers[index].status.color)
                                    .padding(.leading, 20)
                                Text(self.viewModel.servers[index].name)
                                    .padding(.leading, 10)
                                Spacer()
                                Text(self.viewModel.servers[index].server)
                                Spacer()
                                Button(action: {
                                    //                                self.viewModel.serverObject.servers.remove(at: index)
                                    self.hideModifyView = false
                                    self.viewModel.modifyServer(index: index)
                                    self.viewModel.setServers()
                                }){
                                    Text("Modify")
                                }
                                .padding(.trailing, 10)
                                Button(action: {
                                    self.viewModel.servers.remove(at: index)
                                    self.viewModel.setServers()
                                }){
                                    Text("Remove")
                                        .foregroundColor(.red)
                                }
                                .padding(.trailing, 10)
                            }
                            .onChange(of: self.viewModel.servers[index].status, perform: { newValue in
                                switch self.autoUpdateState {
                                case .on:
                                    if newValue == .disconnected {
                                        self.viewModel.notifyDisconnect()
                                    }
                                case .off:
                                    break
                                }
                            })
                        }
                    }
                }
                Spacer()
            }
            .disabled(!self.hideModifyView)
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 400, height: 400, alignment: .center)
                VStack{
                    Text("MODIFY")
                        .foregroundColor(.white)
                    TextField("Type Name", text: self.$viewModel.selectedName)
                        .frame(width: 300, height: 40, alignment: .center)
                    TextField("Type Server(URL)", text: self.$viewModel.selectedURL)
                        .frame(width: 300, height: 40, alignment: .center)
                        .padding(.bottom, 50)
                    HStack(spacing: 20){
                        Button(action: {
                            self.viewModel.confirmModify()
                            self.hideModifyView = true
                        }){
                            Text("Modify")
                        }
                        Button(action: {
                            self.hideModifyView = true
                            self.viewModel.cancelModify()
                        }){
                            Text("Cancel")
                        }
                    }
                }
                .frame(height: 40, alignment: .center)
                
            }
            .isHidden(self.hideModifyView)
        }
        .frame(minWidth: 600, minHeight: 400, alignment: .center)
        .alert("Please type both fields", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                self.showAlert = false
            }
        }
    }
    
    private func addButtonClicked() {
        if self.nameText.isEmpty || self.serverText.isEmpty {
            self.showAlert = true
        } else {
            self.viewModel.addServer(nameText: self.nameText, serverText: self.serverText)
        }
    }
    
    private func stopAction() {
        timer.upstream.connect().cancel()
        self.showStopAlert = true
        self.autoUpdateState  = .off
        for var server in self.viewModel.servers {
            server.status = .standBy
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

extension HomeView {
    final class ViewModel: ObservableObject {
        @Published var servers: [Server] = []
        @Published var timerCount : String = "5"
        @Published var selectedIndex : Int = 0
        @Published var selectedName : String = ""
        @Published var selectedURL : String = ""
        
        let apiSevice: APIServiceProtocol
        let notifyService: NotifyServiceProtocol
        var bag = Set<AnyCancellable>()
        let timerIntervalTextPublisher = PassthroughSubject<String, Never>()
        
        init(apiService: APIServiceProtocol = APIService(), notifyService: NotifyServiceProtocol = NotifyService()) {
            self.apiSevice = apiService
            self.notifyService = notifyService
            self.getServers()
            self.getTimeInterval()
        }
        
        func notifyDisconnect() {
            self.notifyService.notifyDisconnect()
        }
        
        func addServer(nameText: String, serverText: String) {
            let server = Server(name: nameText, server: serverText, status: .standBy)
            self.servers.append(server)
            self.setServers()
        }
        
        func updateServer() {
            for var server in self.servers {
                self.apiSevice.updateServer(server: server)
                    .sink(receiveValue: { result in
                        DispatchQueue.main.async {
                            if result {
                                server.status = .connected
                            } else {
                                server.status = .disconnected
                            }
                        }
                    })
                    .store(in: &bag)
                self.servers.append(Server(name: "", server: "", status: .standBy))
                self.servers.removeLast()
                self.setServers()
            }
        }
        
        func setServers() {
            if let encoded = try? JSONEncoder().encode(self.servers) {
                UserDefaults.standard.set(encoded, forKey: "Servers")
            }
        }
        
        func getServers() {
            if let data = UserDefaults.standard.data(forKey: "Servers") {
                if let decoded = try? JSONDecoder().decode([Server].self, from: data) {
                    self.servers = decoded
                    return
                }
            }
        }
        
        func setTimeInterval() {
            UserDefaults.standard.set(self.timerCount, forKey: "TimeInterval")
        }
        
        func getTimeInterval() {
            if let string = UserDefaults.standard.string(forKey: "TimeInterval") {
                self.timerCount = string
                return
            }
        }
        
        func modifyServer(index: Int) {
            self.selectedIndex = index
            self.selectedName = self.servers[index].name
            self.selectedURL = self.servers[index].server
        }
        
        func confirmModify() {
            self.servers[self.selectedIndex].name = self.selectedName
            self.servers[self.selectedIndex].server = self.selectedURL
            self.setServers()
        }
        
        func cancelModify() {
            self.selectedURL = ""
            self.selectedName = ""
            self.selectedIndex = 0
        }
    }
}
