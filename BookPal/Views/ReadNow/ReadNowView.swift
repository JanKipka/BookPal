//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI
import Foundation
import CoreData

struct ReadNowView: View {
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: #keyPath(ReadingCycle.startedAt), ascending: true)
    ]) var cycles: FetchedResults<ReadingCycle>
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: #keyPath(ReadingActivity.startedAt), ascending: true)
    ], predicate: NSPredicate(format: "active = true")) var activities: FetchedResults<ReadingActivity>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "year = %i", Int(Calendar.current.component(.year, from: Date())))) var goals: FetchedResults<Goal>
    @Environment(\.managedObjectContext) var moc
    
    let dataController = DataController.shared
    let readingController = ReadingController()
    
    @State var navigateToNewCycleView: Bool = false
    @State var navigateToActivityView: Bool = false
    @State var activityStartedAlert: Bool = false
    @State var hasActiveActivityAlert: Bool = false
    @State var showCancelWarning: Bool = false
    @State var selectedActivity: ReadingActivity?
    @State var selectedCycleToStop: ReadingCycle?
    @State var showSearchSheet = false
    @State var titleAsString = ""
    @State var selectedVolume: VolumeInfo = VolumeInfo()
    @State var searchMode: SearchMode = .query
    @State var presentReadingGoalView = false
    @State var tappedGoal: Goal?
    
    
    func startReadingActivityForCycle(_ cycle: ReadingCycle) {
        let hasActiveActivities = !activities.isEmpty
        if hasActiveActivities {
            hasActiveActivityAlert.toggle()
            return
        }
        let _ = readingController.createNewActivity(readingCycle: cycle, onPage: cycle.currentPage)
        activityStartedAlert.toggle()
    }
    
    fileprivate func putBookAway(_ cycle: ReadingCycle) {
        readingController.stopReading(cycle: cycle)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                    .ignoresSafeArea()
                VStack {
                    List {
                        Section(LocalizedStringKey("active-activities")) {
                            ForEach(activities) { ac in
                                Button {
                                    selectedActivity = ac
                                } label: {
                                    ReadingActivityComponent(readingActivity: ac)
                                }
                                .foregroundColor(.primary)
                                .sheet(item: $selectedActivity) { activity in
                                    ReadingActivityDetailView(readingActivity: activity)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        selectedActivity = ac
                                    } label: {
                                        Label("finish", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                        
                        Section(LocalizedStringKey("books-reading")) {
                            ForEach(cycles.filter({$0.active}).sorted(by: {$0.lastUpdated > $1.lastUpdated})) { cycle in
                                NavigationLink(destination: ReadingCycleDetailView(readingCycle: cycle)) {
                                    ReadingCycleComponent(readingCycle: cycle)
                                }
                                .swipeActions(edge: .leading){
                                    if cycle.active {
                                        Button {
                                            startReadingActivityForCycle(cycle)
                                        } label: {
                                            Label("read-now", systemImage: "book.fill")
                                        }
                                        .tint(.blue)
                                        Button {
                                            showCancelWarning = true
                                            selectedCycleToStop = cycle
                                        } label: {
                                            Label("Put Away", systemImage: "stop.circle.fill")
                                        }
                                        .tint(.red)
                                    } else {
                                        EmptyView()
                                    }
                                    
                                }
                            }
                            
                        }
                        if goals.count == 0 {
                            VStack(alignment: .center, spacing: 20) {
                                Text("no-goals-set")
                                    .font(.system(size: 20))
                                Button() {
                                    presentReadingGoalView = true
                                } label: {
                                    Text("set-goals")
                                        .fontWeight(.semibold)
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(.blue))
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .sheet(isPresented: $presentReadingGoalView) {
                                    ReadingGoalView()
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        ForEach(goals) { goal in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your reading goals for \(String(Calendar.current.component(.year, from: Date.now)))")
                                    .fontWeight(.semibold)
                                    .listRowBackground(Color.clear)
                                    .font(.system(size: 22))
                                    .listRowSeparator(.hidden)
//                                HStack {
                                    if goal.numOfBooks > 0 {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                ProgressView(value: Double(goal.cycles?.count ?? 0), total: Double(goal.numOfBooks))
                                                    .progressViewStyle(CircularProgressBarStyle())
                                                    .frame(width: 65, height: 65)
                                                Text("\(goal.cycles?.count ?? 0) of \(goal.numOfBooks) books read")
                                            }
                                        }
                                    }
                                    if goal.interval > 0 {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                ProgressView(value: goal.totalTimeRead, total: Double(goal.interval))
                                                    .progressViewStyle(CircularProgressBarStyle())
                                                    .frame(width: 65, height: 65)
                                                TimelineView(.everyMinute) { _ in
                                                    Text("\(goal.totalTimeRead.asDaysHoursMinutesString ?? "") of \(TimeInterval(goal.interval).asDaysHoursMinutesString ?? "") read")
                                                }
                                                
                                            }
                                        }.padding(.bottom, 10)
                                    }
//                                }
//                                .padding(.bottom, 10)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                tappedGoal = goal
                            }
                            .sheet(item: $tappedGoal) { g in
                                ReadingGoalView(goal: g)
                            }
                        }
                    }
                    
                }
                .alert(isPresented: $activityStartedAlert) {
                    Alert(title: Text("Reading activity started!"))
                }
                .alert(isPresented: $hasActiveActivityAlert) {
                    Alert(title: Text("Active activity ongoing"), message: Text("already-active"))
                }
                .alert("Are you sure you want to put this book away?", isPresented: $showCancelWarning) {
                    Button("Yes") {
                        putBookAway(selectedCycleToStop!)
                    }
                    Button("No", role: .cancel) {}
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Dev: Delete all") {
                            dataController.deleteAll(entityName: "Genre")
                            dataController.deleteAll(entityName: "Book")
                            dataController.deleteAll(entityName: "Author")
                            dataController.deleteAll(entityName: "ReadingCycle")
                            dataController.deleteAll(entityName: "ReadingActivity")
                            dataController.deleteAll(entityName: "CoverLinks")
                        }
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearchSheet = true
                    } label: {
                        Label("Add new book", systemImage: "magnifyingglass")
                    }
                    .sheet(isPresented: $showSearchSheet, onDismiss: {
                        titleAsString = selectedVolume.title ?? ""
                        navigateToNewCycleView = !titleAsString.isEmpty
                    }){
                        SearchView(selectedVolume: $selectedVolume, searchMode: $searchMode)
                    }
                    .sheet(isPresented: $navigateToNewCycleView, onDismiss: {
                        selectedVolume = VolumeInfo()
                    }) {
                        AddBookView(selectedVolume: $selectedVolume, titleAsString: $titleAsString, searchMode: $searchMode)
                    }
                }
            }
            .navigationTitle("read-now")
            
        }
    }
    
    func filterActivities() -> [ReadingActivity] {
        return activities.filter({$0.finishedAt == nil})
    }
    
    func filterCycles() -> [ReadingCycle] {
        return cycles.filter({$0.active})
    }
}

struct ReadingGoalView: View {
    
    @State var numOfBooks = ""
    @State var totalHours = "0"
    @State var totalMinutes = "0"
    @State var isAmount = true
    @State var isHours = false
    @State var perDay: Bool = true
    let currentYear = Calendar.current.component(.year, from: Date.now)
    var goal: Goal?
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    init() {
        goal = Goal(context: moc)
    }
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    var hoursDisabled: Color {
        return !isHours ? .gray : .white
    }
    
    var amountDisabled:  Color  {
        return !isAmount ? .gray : .white
    }
    
    var body: some View {
        ZStack {
            Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        ReadingGoalToggleComponent(isOn: $isAmount, title: "Books")
                    }
                    Group {
                        Text("I want to read...")
                            .font(.system(size: 32))
                        TextField(text: $numOfBooks) {
                            Text("...")
                                .font(.system(size: 20))
                        }
                        .submitLabel(.return)
                        .disabled(!isAmount)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(amountDisabled))
                        .foregroundColor(.black)
                        Text("books in \(String(currentYear)).")
                            .font(.system(size: 32))
                    }
                    
                    Spacer()
                    Group {
                        ReadingGoalToggleComponent(isOn: $isHours, title: "Time")
                    }
                    Group {
                        Text("And at least this many...")
                            .font(.system(size: 32))
                        HStack {
                            ReadingGoalTimeComponent(timeComponent: $totalHours, enabled: $isHours, backgroundColor: hoursDisabled, title: "Hours")
                            ReadingGoalTimeComponent(timeComponent: $totalMinutes, enabled: $isHours, backgroundColor: hoursDisabled, title: "Minutes")
                        }
                        Picker("", selection: $perDay) {
                            Text("Per Day")
                                .tag(true)
                            Text("Per Week")
                                .tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .disabled(!isHours)
                    }
                    
                    Spacer()
                    Button {
                        if goal!.id == nil {
                            goal!.id = UUID()
                            goal!.year = Int16(currentYear)
                        }
                        
                        if isAmount {
                            goal!.numOfBooks = Int16(numOfBooks)!
                        } else {
                            goal!.numOfBooks = 0
                        }
                        if isHours {
                            let numOfHoursInSeconds = ((Int(totalHours) ?? 0)) * 3600
                            let minutesInSeconds = (Int(totalMinutes) ?? 0) * 60
                            let interval = numOfHoursInSeconds + minutesInSeconds
                            goal!.interval = Int64(interval)
                            goal!.perDay = perDay
                        } else {
                            goal!.interval = 0
                        }
                        DataController.shared.save()
                        dismiss()
                    } label: {
                        Text("Set")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 8).fill(.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!isAmount && !isHours)
                    
                    
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .onAppear {
                    self.isAmount = goal!.numOfBooks > 0
                    self.numOfBooks = isAmount ? String(goal!.numOfBooks) : ""
                    self.isHours = goal!.interval > 0
                    let interval = TimeInterval(goal!.interval)
                    let daysHoursMinutes = interval.daysHoursMinutes
                    self.totalHours = String(daysHoursMinutes[1])
                    self.totalMinutes = String(daysHoursMinutes[2])
                    self.perDay = goal?.perDay ?? true
                }
            }
        }
    }
}

struct ReadingGoalViewPreview: PreviewProvider {
    static var previews: some View {
        ReadingGoalView()
    }
}

struct  ReadingGoalTimeComponent: View {
    
    @Binding var timeComponent: String
    @Binding var enabled: Bool
    var backgroundColor: Color
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
                .fontWeight(.semibold)
            TextField(text: $timeComponent) {
            }
            .submitLabel(.return)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .disabled(!enabled)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(backgroundColor))
            .foregroundColor(.black)
        }
    }
}

struct ReadingGoalToggleComponent: View {
    
    @Binding var isOn: Bool
    var title: String
    
    var body: some View {
        Toggle(isOn: $isOn, label: {
            Text(title)
                .font(.system(size: 22))
                .fontWeight(.semibold)
        })
            .frame(maxWidth: 200)
    }
}
