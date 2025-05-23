
protocol NewScheduleControllerDelegate: AnyObject {
    func didUpdateSchedule(_ schedule: Set<WeekDay>)
}
