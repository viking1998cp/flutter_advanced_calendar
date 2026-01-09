import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _calendarControllerToday = AdvancedCalendarController.today();

  // Example event map with GĐCT and GĐHT events
  Map<DateTime, CalendarModel> get eventMap {
    final now = DateTime.now();
    // Use UTC with hour 12 to match toZeroTime() behavior
    final today = DateTime.utc(now.year, now.month, now.day, 12);

    return {
      // Example: Today has 1 GĐCT event
      today: const CalendarModel(
        returned: CalendarValueModel(
          count: 5,
          bgColor: "#FFA726",
        ),
        done: CalendarValueModel(
          count: 1,
          bgColor: "#4CAF50",
        ),
        overdue: CalendarValueModel(
          count: 0,
          bgColor: "#F44336",
        ),
      ),
      // Example: Tomorrow has 2 events (GĐCT and GĐHT)
      DateTime.utc(now.year, now.month, now.day + 1, 12): const CalendarModel(
        returned: CalendarValueModel(
          count: 5,
          bgColor: "#FFA726",
        ),
        done: CalendarValueModel(
          count: 1,
          bgColor: "#4CAF50",
        ),
        overdue: CalendarValueModel(
          count: 1,
          bgColor: "#F44336",
        ),
      ),
      // Example: Day after tomorrow has 2 events
      DateTime.utc(now.year, now.month, now.day + 2, 12): const CalendarModel(
        returned: CalendarValueModel(
          count: 5,
          bgColor: "#FFA726",
        ),
        done: CalendarValueModel(
          count: 0,
          bgColor: "#4CAF50",
        ),
        overdue: CalendarValueModel(
          count: 0,
          bgColor: "#F44336",
        ),
      ),
    };
  }

  @override
  void initState() {
    super.initState();
    // _calendarControllerToday.v
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi', 'VN'), // Tiếng Việt
            Locale('en', 'US'), // Tiếng Anh
          ],
          home: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Lịch Việt Nam'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Builder(
              builder: (context) {
                return AdvancedCalendar(
                  showNavigationArrows: true,
                  disableScroll: true,
                  showHandleBar: false,
                  controller: _calendarControllerToday,
                  eventMap: eventMap,
                  startWeekDay: 1,
                  weekLineHeight: 100.h,
                  innerDot: true,
                  keepLineSize: true,
                  getFirstAndLastWeek: (first, last) {},
                );
              },
            ),
          ),
        );
      },
    );
  }
}
