import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_june_client/constants.dart';

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}

class MailService {
  const MailService();

  String getNextMailReceiveTimeStr() {
    TimeOfDay now = TimeOfDay.fromDateTime(clock.now());
    if (now.compareTo(ProjectConstants.mailReceiveTime) >= 0) {
      return "내일 저녁 9시";
    }
    return "오늘 저녁 9시";
  }

  int getMailDateDiff(DateTime targetDate, DateTime firstMailDate) {
    DateTime normalizedDt =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    DateTime normalizedFirstMailDate =
        DateTime(firstMailDate.year, firstMailDate.month, firstMailDate.day);
    return normalizedDt.difference(normalizedFirstMailDate).inDays;
  }

  String getMailReceiveDateStr(DateTime targetDate, bool needMonth) {
    if (needMonth || targetDate.day == 1) {
      return DateFormat('M월 d일').format(targetDate);
    }
    return DateFormat('d').format(targetDate);
  }

  String formatMailDate(DateTime dt) {
    return DateFormat('yyyy.MM.dd').format(dt);
  }

  List<Widget> emptyCellsForWeekDay(DateTime firstDate) {
    return List.generate(
        (firstDate.weekday - DateTime.sunday) % 7, (index) => const SizedBox());
  }

  Widget calendarWeekday() {
    final List<String> weekdays = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat'
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        for (var day in weekdays)
          Text(
            day,
            style: TextStyle(
              color: ColorConstants.gray,
              fontWeight: FontWeightConstants.semiBold,
            ),
          ),
      ],
    );
  }

  String kMonthData(index) {
    switch (index) {
      case 1:
        return '첫 번째 달';
      case 2:
        return '두 번째 달';
      case 3:
        return '세 번째 달';
      case 4:
        return '네 번째 달';
      case 5:
        return '다섯 번째 달';
      case 6:
        return '여섯 번째 달';
      case 7:
        return '일곱 번째 달';
      case 8:
        return '여덟 번째 달';
      case 9:
        return '아홉 번째 달';
      case 10:
        return '열 번째 달';
      case 11:
        return '열한 번째 달';
    }
    return '';
  }
}
