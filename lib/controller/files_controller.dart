import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:file_manager_app/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_info/storage_info.dart';

class FilesController extends GetxController {
  final FileManagerController controller = FileManagerController();

  double deviceAvailableSize = 0;
  double deviceTotalSize = 0;

  var documentSize = 0.0;
  var videoSize = 0.0;
  var imageSize = 0.0;
  var soundSize = 0.0;

  @override
  void onInit() {
    super.onInit();

    _getSpace().then((value) {
      update();
    });
  }

  Future<void> _getSpace() async {
    deviceAvailableSize = await StorageInfo.getStorageFreeSpaceInGB;
    deviceTotalSize = await StorageInfo.getStorageTotalSpaceInGB + 10;
    update();
  }

  Future<void> selectStorage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map((e) => ListTile(
                              title: Text(
                                FileManager.basename(e),
                              ),
                              onTap: () {
                                controller.openDirectory(e);
                                Navigator.pop(context);
                              },
                            ))
                        .toList()),
              );
            }
            return const Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  title: const Text("Name"),
                  onTap: () {
                    controller.sortBy(SortBy.name);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Size"),
                  onTap: () {
                    controller.sortBy(SortBy.size);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("Date"),
                  onTap: () {
                    controller.sortBy(SortBy.date);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text("type"),
                  onTap: () {
                    controller.sortBy(SortBy.type);
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  createFile(BuildContext context, String path) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController fileName = TextEditingController();
        TextEditingController fileSize = TextEditingController();
        TextEditingController fileExtension = TextEditingController();
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "File Name",
                    ),
                    controller: fileName,
                  ),
                ),
                ListTile(
                  trailing: const Text("Bytes"),
                  title: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "File Size",
                    ),
                    controller: fileSize,
                  ),
                ),
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "File Extension",
                    ),
                    controller: fileExtension,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    primary: orage2,
                  ),
                  onPressed: () async {
                    Directory documentsDir =
                        await getApplicationDocumentsDirectory();

                    String folderPath = path;
                    try {
                      Directory folder = Directory(folderPath);
                      if (!await folder.exists()) {
                        await folder.create(recursive: true);
                      }
                      File file = File(
                          '$folderPath/${fileName.text}.${fileExtension.text}');
                      if (!await file.exists()) {
                        await file.create();
                        RandomAccessFile raf =
                            await file.open(mode: FileMode.write);
                        for (int i = 0; i < int.parse(fileSize.text); i++) {
                          await raf.writeByte(0x00);
                        }

                        await raf.close().then((value) {
                          Navigator.pop(context);
                        });
                      }
                    } catch (e) {
                      alert(context, "somthing went wrong");
                    }
                  },
                  child: const Text(
                    'Create File',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
    update();
  }

  createFolder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController folderName = TextEditingController();
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    decoration: const InputDecoration(
                      hintText: "Folder Name",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    controller: folderName,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    primary: orage2,
                  ),
                  onPressed: () async {
                    if (folderName.text.isEmpty || folderName.text == "") {
                      return;
                    }

                    try {
                      await FileManager.createFolder(
                              controller.getCurrentPath, folderName.text)
                          .then((value) {
                        Navigator.pop(context);
                        controller.setCurrentPath =
                            "${controller.getCurrentPath}/${folderName.text}";
                      });
                    } catch (e) {
                      alert(context, "Folder already exists");
                    }
                    update();
                  },
                  child: const Text(
                    'Create Folder',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> alert(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(message),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  primary: orage2,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  calculateSize(List<FileSystemEntity> entities) {
    documentSize = 0;
    videoSize = 0;
    imageSize = 0;
    soundSize = 0;
    for (var i = 0; i < entities.length; i++) {
      if (entities[i].path.contains(".pdf") ||
          entities[i].path.contains(".doc") ||
          entities[i].path.contains(".txt") ||
          entities[i].path.contains(".ppt") ||
          entities[i].path.contains(".docx") ||
          entities[i].path.contains(".pptx") ||
          entities[i].path.contains(".xlsx") ||
          entities[i].path.contains(".xls")) {
        documentSize += entities[i].statSync().size / 1000000;
      }
      if (entities[i].path.contains(".mp4") ||
          entities[i].path.contains(".mkv") ||
          entities[i].path.contains(".avi") ||
          entities[i].path.contains(".flv") ||
          entities[i].path.contains(".wmv") ||
          entities[i].path.contains(".mov") ||
          entities[i].path.contains(".3gp") ||
          entities[i].path.contains(".webm")) {
        videoSize += entities[i].statSync().size / 1000000;
      }
      if (entities[i].path.contains(".jpg") ||
          entities[i].path.contains(".jpeg") ||
          entities[i].path.contains(".png") ||
          entities[i].path.contains(".gif") ||
          entities[i].path.contains(".bmp") ||
          entities[i].path.contains(".webp")) {
        imageSize += (entities[i].statSync().size / 1000000);
      }
      if (entities[i].path.contains(".mp3") ||
          entities[i].path.contains(".wav") ||
          entities[i].path.contains(".aac") ||
          entities[i].path.contains(".ogg") ||
          entities[i].path.contains(".wma") ||
          entities[i].path.contains(".flac") ||
          entities[i].path.contains(".m4a")) {
        soundSize += entities[i].statSync().size / 1000000;
      }
    }

    update();
  }
}
