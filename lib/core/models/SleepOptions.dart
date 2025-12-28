class SleepOption {
  final String label;
  final Duration? duration;

  const SleepOption({required this.label, required this.duration});
}

const List<SleepOption> sleepOptions = [
  SleepOption(label: '5 phút', duration: Duration(minutes: 5)),
  SleepOption(label: '15 phút', duration: Duration(minutes: 15)),
  SleepOption(label: '30 phút', duration: Duration(minutes: 30)),
  SleepOption(label: '60 phút', duration: Duration(minutes: 60)),
  SleepOption(label: '90 phút', duration: Duration(minutes: 90)),
];
