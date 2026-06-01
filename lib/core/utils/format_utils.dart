import 'package:intl/intl.dart';

extension IntFormat on int {
  String toFormattedString() {
    return NumberFormat('#,###', 'id_ID').format(this);
  }
}
