import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _calendarControllerToday = AdvancedCalendarController.today();

  // Example event map with GĐCT and GĐHT events
  Map<DateTime, List<CalendarEvent>> get eventMap {
    final now = DateTime.now();
    // Use UTC with hour 12 to match toZeroTime() behavior
    final today = DateTime.utc(now.year, now.month, now.day);

    return {
      // Example: Today has 1 GĐCT event
      today: [
        const CalendarEvent(type: 'GĐCT', quantity: 1),
      ],
      // Example: Tomorrow has 2 events (GĐCT and GĐHT)
      DateTime.utc(now.year, now.month, now.day + 1, 12): [
        const CalendarEvent(type: 'GĐCT', quantity: 2),
        const CalendarEvent(type: 'GĐHT', quantity: 2),
      ],
      // Example: Day after tomorrow has 2 events
      DateTime.utc(now.year, now.month, now.day + 2, 12): [
        const CalendarEvent(type: 'GĐCT', quantity: 2),
        const CalendarEvent(type: 'GĐHT', quantity: 3),
      ],
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
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AdvancedCalendar(
                      showNavigationArrows: false,
                      disableScroll: true,
                      showHandleBar: false,
                      controller: _calendarControllerToday,
                      eventMap: eventMap,
                      startWeekDay: 1,
                      weekLineHeight: 80.h,
                      innerDot: true,
                      keepLineSize: true,
                      calendarTextStyle: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5125,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
