import 'dart:io';

import 'package:diary_journal/theme/theme_color.dart';
import 'package:diary_journal/views/home/note_model/note_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:diary_journal/views/home/details_screen/details_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../create/local_widget/mood.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DetailsView extends StatelessWidget {
  final Note note;
  final int noteIndex;
  final File? imageFile;

  DetailsView({
    Key? key,
    required this.note,
    required this.noteIndex,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DetailsController detailsController = Get.put(
      DetailsController(
        noteIndex: noteIndex,
        initialImageFile: imageFile, // Pass the imageFile as initialImageFile
      ),
    );

    String? selectedEmojiName;
    Map<String, Emoji> emojiMap = {};

    void saveEmojiLocally(Emoji emoji) async {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final emojiPath = '${appDir.path}/selected_emoji.txt';

        // Write the selected emoji name to a file
        await File(emojiPath).writeAsString(emoji.name);

        selectedEmojiName = emoji.name;
        emojiMap[emoji.name] = emoji;
      } catch (error) {
        print('Error saving emoji: $error');
      }
    }

    Future<void> showImagePickerDialog(BuildContext context) async {
      final shouldUpdateImage = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Select Image Source",
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ThemeColor.mainColor,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ButtonTheme(
                    minWidth: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                        await detailsController.takePhoto();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: ThemeColor.blueColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Take a picture",
                            style: TextStyle(
                              fontFamily: 'KantumruyPro',
                              fontSize: 14,
                              color: ThemeColor.blueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ButtonTheme(
                    minWidth: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                        await detailsController.pickImageFromGallery();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.photo,
                            size: 20,
                            color: ThemeColor.blueColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Choose from gallery",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'KantumruyPro',
                              color: ThemeColor.blueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );

      if (shouldUpdateImage != null && shouldUpdateImage) {
        final File? imageFile = detailsController.imageFile.value;
        if (imageFile != null) {
          await detailsController.saveImageToStorage(imageFile);
        }
      }
    }

    Future<void> showEmojiPicker(BuildContext context) async {
      final emoji = await showModalBottomSheet<Emoji>(
        context: context,
        builder: (BuildContext context) {
          return EmojiPicker(
            onEmojiSelected: (Category? category, Emoji? emoji) {
              if (emoji != null) {
                saveEmojiLocally(emoji);
                Navigator.of(context).pop();
              }
            },
            config: const Config(
              columns: 7,
            ),
          );
        },
      );

      if (emoji != null) {
        print("Selected Emoji: ${emoji.emoji}");
      }
    }

    List<Mood> moods = [
      Mood(
        iconPath: 'assets/images/Awsome.png',
        name: 'Awsome',
        size: 24,
        color: ThemeColor.successColor,
      ),
      Mood(
          iconPath: 'assets/images/Happy.png',
          name: 'Happy',
          size: 24,
          color: ThemeColor.happyColor),
      Mood(
        iconPath: 'assets/images/Neutral.png',
        name: 'Neutral',
        size: 24,
        color: ThemeColor.nautralColor,
      ),
      Mood(
        iconPath: 'assets/images/Bad.png',
        name: 'Bad',
        size: 24,
        color: ThemeColor.badColor,
      ),
      Mood(
        iconPath: 'assets/images/Awful.png',
        name: 'Awful',
        size: 24,
        color: ThemeColor.awfulColor,
      ),
    ];

    Future<void> showColorPicker(BuildContext context, Mood mood) async {
      Color pickerColor = mood.color;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (Color color) {
                  // Update the mood's color with the selected color
                  mood.color = color;
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    Future<void> showMoodPicker(BuildContext context) async {
      final selectedMood = await showModalBottomSheet<Mood>(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    // Open color picker when the mood icon is tapped
                    showColorPicker(context, mood);
                  },
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      mood.color,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      mood.iconPath,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                title: Text(mood.name),
                onTap: () {
                  // Update the selected mood in the controller
                  detailsController.setSelectedMood(mood);

                  Navigator.of(context).pop(mood);
                },
              );
            },
          );
        },
      );

      if (selectedMood != null) {
        print("Selected Mood: ${selectedMood.name}");
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.mainColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ThemeColor.colorScheme.onSurface,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: Text(
          'Edit Journal Entry',
          style: TextStyle(color: ThemeColor.colorScheme.onSurface),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      detailsController.decrementDay();
                    },
                    borderRadius: BorderRadius.circular(17.5),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: ThemeColor.mainColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chevron_left,
                          color: ThemeColor.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Obx(
                      () => TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: ThemeColor.mainColor,
                        ),
                        child: Text(
                          DateFormat.yMMMd()
                              .format(detailsController.date.value),
                          style: TextStyle(
                            color: ThemeColor.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      detailsController.incrementDay();
                    },
                    borderRadius: BorderRadius.circular(17.5),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: ThemeColor.mainColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chevron_right,
                          color: ThemeColor.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: ElevatedButton(
                      onPressed: () {
                        detailsController.saveJournalEntry();

                        // Get.snackbar(
                        //   'Saved Note',
                        //   '${detailsController.imageFile.value}\nTitle: ${detailsController.title.value}\nDescription: ${detailsController.description.value}\nMood: ${detailsController.selectedMood.value}',
                        //   snackPosition: SnackPosition.TOP,
                        //   duration: const Duration(seconds: 5),
                        // );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.mainColor,
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontFamily: 'KantumruyPro',
                          color: ThemeColor.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColor.blueColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return detailsController.imageFile.value != null &&
                                detailsController.imageFile.value!.existsSync()
                            ? SizedBox(
                                height: 200,
                                child: Image.file(
                                  detailsController.imageFile.value!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container();
                      }),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: detailsController.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ThemeColor.colorScheme.onSurface,
                              ),
                              onChanged: (value) =>
                                  detailsController.setTitle(value),
                              decoration: InputDecoration(
                                hintText: 'What is your title?',
                                hintStyle: TextStyle(
                                  color: ThemeColor.colorScheme.onSurface,
                                  fontFamily: 'KantumruyPro',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showImagePickerDialog(context);
                                  },
                                  icon: Icon(
                                    Icons.photo,
                                    color: ThemeColor.colorScheme.onSurface,
                                    size: 24,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showMoodPicker(context);
                                  },
                                  icon: selectedEmojiName != null
                                      ? Text(
                                          emojiMap[selectedEmojiName!]?.emoji ??
                                              '',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: ThemeColor
                                                .colorScheme.onSurface,
                                          ),
                                        )
                                      : Icon(
                                          Icons.emoji_emotions,
                                          color:
                                              ThemeColor.colorScheme.onSurface,
                                          size: 24,
                                        ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    List<String> shareTexts = [
                                      'Title: ${detailsController.title}',
                                      'Description: ${detailsController.description}'
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
                                  icon: Icon(
                                    Icons.share,
                                    color: ThemeColor.colorScheme.onSurface,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      TextField(
                        controller: detailsController.description,
                        style: TextStyle(
                          color: ThemeColor.colorScheme.onSurface,
                        ),
                        maxLines: null,
                        onChanged: (value) =>
                            detailsController.setDescription(value),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "What's on your mind?",
                          hintStyle: TextStyle(
                            fontFamily: 'KantumruyPro',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ThemeColor.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
