class CalendarModel {
  const CalendarModel({
    this.returned,
    this.done,
    this.overdue,
  });

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      returned: json['returned'] != null ? CalendarValueModel.fromJson(json['returned']) : null,
      done: json['done'] != null ? CalendarValueModel.fromJson(json['done']) : null,
      overdue: json['overdue'] != null ? CalendarValueModel.fromJson(json['overdue']) : null,
    );
  }

  final CalendarValueModel? returned;
  final CalendarValueModel? done;
  final CalendarValueModel? overdue;

  Map<String, dynamic> toJson() {
    return {
      'returned': returned?.toJson(),
      'done': done?.toJson(),
      'overdue': overdue?.toJson(),
    };
  }
}

class CalendarValueModel {
  const CalendarValueModel({
    this.count,
    this.bgColor,
  });

  factory CalendarValueModel.fromJson(Map<String, dynamic> json) {
    return CalendarValueModel(
      count: json['count'],
      bgColor: json['bg_color'],
    );
  }
  final int? count;
  final String? bgColor;

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'bg_color': bgColor,
    };
  }
}
