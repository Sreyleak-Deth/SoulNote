import 'dart:io';
import 'package:diary_journal/theme/theme_color.dart';
import 'package:diary_journal/views/home/details_screen/details_view.dart';
import 'package:diary_journal/views/home/home_controller.dart';
import 'package:diary_journal/widget/custom_app_bar.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);
  final HomeController homeController = Get.put(HomeController());
  Future<void> fetchData() async {
    await homeController.fetchDataFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: CustomAppBar(),
        backgroundColor: ThemeColor.mainColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: homeController.searchController,
                  onChanged: (value) {
                    homeController.searchNotes(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          EasyDateTimeLine(
            initialDate: Get.put(HomeController()).selectedDate.value,
            onDateChange: (selectedDate) {
              Get.put(HomeController()).updateSelectedDate(selectedDate);
            },
            activeColor: ThemeColor.colorScheme.primary,
            dayProps: EasyDayProps(
              todayHighlightStyle: TodayHighlightStyle.withBackground,
              todayHighlightColor: ThemeColor.mainColor,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeColor.mainColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  var controller = Get.find<HomeController>();
                  return ListView.builder(
                    // itemCount: controller.notes.length,
                    // itemBuilder: (context, index) {
                    //   final note = controller.notes[index];

                    itemCount: homeController.filteredNotes.isNotEmpty
                        ? homeController.filteredNotes.length
                        : controller.notes.length,
                    itemBuilder: (context, index) {
                      final note = homeController.filteredNotes.isNotEmpty
                          ? homeController.filteredNotes[index]
                          : controller.notes[index];
                      // Check if note has an imagePath
                      Widget imageWidget =
                          const SizedBox(); // Default empty widget
                      if (note.imagePath != null &&
                          note.imagePath!.isNotEmpty) {
                        imageWidget = Image.file(
                          File(note.imagePath!),
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      } else {
                        imageWidget = Image.asset(
                          'assets/images/default_image.jpg',
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      }
                      Widget moodIconWidget = Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: homeController
                                  .moodIconBackgroundColors[note.mood ?? ''] ??
                              ThemeColor.colorScheme.secondaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              note.mood ?? 'assets/images/Awsome.png',
                              width: 25,
                              height: 25,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                      return Slidable(
                        actionPane: const SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        actions: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: IconSlideAction(
                              caption: 'Share',
                              color: ThemeColor.colorScheme.primary,
                              icon: Icons.share,
                              onTap: () {
                                List<String> shareTexts = [
                                  'Title: ${note.title}',
                                  'Description: ${note.description}'
                                ];
                                String shareText = shareTexts.join('\n\n');
                                if (note.imagePath != null &&
                                    note.imagePath!.isNotEmpty) {
                                  Share.shareFiles([note.imagePath!],
                                      text: shareText);
                                } else {
                                  Share.share(shareText);
                                }
                              },
                            ),
                          ),
                        ],
                        secondaryActions: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: IconSlideAction(
                              caption: 'Edit',
                              color: ThemeColor.blueColor,
                              icon: Icons.edit,
                              onTap: () async {
                                // Fetch the selected image file
                                File? selectedImageFile = await homeController
                                    .getImageFileFromNote(note);
                                // Navigate to the details view with the image file
                                Get.to(
                                  DetailsView(
                                    note: note,
                                    noteIndex: index,
                                    imageFile: selectedImageFile,
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: IconSlideAction(
                              caption: 'Delete',
                              color: ThemeColor.colorScheme.error,
                              icon: Icons.delete,
                              // onTap: () {
                              //   // await controller.deleteNoteFromApi(
                              //   //     controller.notes[index].id);
                              //   controller.deleteNoteByIndex(index);
                              // },
                              onTap: () async {
                                await controller.deleteNoteFromApi(
                                    index); // Delete the note from the API
                                controller.deleteNoteByIndex(
                                    index); // Delete the note from UI and SharedPreferences
                              },
                            ),
                          ),
                        ],
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                          ),
                          child: ListTile(
                            leading: SizedBox(
                              width: 80,
                              height: 50,
                              child: imageWidget, // Use the image widget here
                            ),
                            title: Text(
                              note.title,
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                color: ThemeColor.colorScheme.background,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              note.description,
                              maxLines: 3,
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                color: ThemeColor.colorScheme.background,
                                fontSize: 14,
                              ),
                            ),
                            trailing: moodIconWidget,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
