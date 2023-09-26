import 'dart:io';

import 'package:diary_journal/theme/theme_color.dart';
import 'package:diary_journal/views/create/create_controller.dart';
import 'package:diary_journal/views/create/local_widget/mood.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

class JournalBox extends StatefulWidget {
  const JournalBox({Key? key}) : super(key: key);

  @override
  _JournalBoxState createState() => _JournalBoxState();
}

class _JournalBoxState extends State<JournalBox> {
  late String selectedMoodIconPath;
  late CreateController createController;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set a default mood when the
    // widget initializes
    createController = Get.put(CreateController());
    createController.setSelectedMood(moods[0]); // Set the first mood as default

    selectedMoodIconPath = createController.selectedMood.value?.iconPath ??
        'assets/images/Awsome.png';

    createController.selectedMood.listen((mood) {
      if (mounted) {
        setState(() {
          selectedMoodIconPath = mood?.iconPath ?? 'assets/images/Awsome.png';
        });
      }
    });
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
                      await createController.takePhoto();
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
                      await createController.pickImageFromGallery();
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
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'KantumruyPro',
                  color: ThemeColor.mainColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldUpdateImage != null && shouldUpdateImage) {
      final File? imageFile = createController.imageFile.value;
      if (imageFile != null) {
        await createController.saveImageToStorage(imageFile);
        setState(() {});
      }
    }
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
                createController.setSelectedMood(mood);

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

  Future<void> showColorPicker(BuildContext context, Mood mood) async {
    Color pickerColor =
        mood.color; // Initialize the picker color with the mood's color

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                setState(() {
                  pickerColor = color;
                });
              },
              showLabel: true, // Show color value label
              pickerAreaHeightPercent: 0.8, // Adjust the picker area height
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the color picker dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the mood's color with the selected color
                setState(() {
                  mood.color = pickerColor;
                });
                Navigator.of(context).pop(); // Close the color picker dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.blueColor,
        borderRadius: BorderRadius.circular(20),
      ),
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  return createController.imageFile.value != null &&
                          createController.imageFile.value!.existsSync()
                      ? SizedBox(
                          height: 200,
                          child: Image.file(
                            createController.imageFile.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container();
                }),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: titleController,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.colorScheme.onSurface,
                        ),
                        onChanged: (value) {
                          createController.setTitle(value);
                        },
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
                            // ignore: unnecessary_null_comparison
                            icon: createController.selectedMood != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ThemeColor.colorScheme.onSurface,
                                    ),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        createController
                                            .selectedMood.value!.color,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                        selectedMoodIconPath,
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.emoji_emotions,
                                    color: ThemeColor.colorScheme.onSurface,
                                    size: 24,
                                  ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(
                          //     Icons.share,
                          //     color: ThemeColor.colorScheme.onSurface,
                          //     size: 24,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(
                    color: ThemeColor.colorScheme.onSurface,
                  ),
                  maxLines: null,
                  onChanged: (value) {
                    createController.setDescription(value);
                  },
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
