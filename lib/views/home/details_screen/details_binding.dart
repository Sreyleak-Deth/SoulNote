import 'package:get/get.dart';

// ignore: camel_case_types
class detailBinding extends Bindings {
  final int noteIndex = 0;
  @override
  void dependencies() {
    // Get.lazyPut(() => DetailsController(noteIndex: noteIndex));
  }
}
