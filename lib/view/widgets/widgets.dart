import 'dart:io';

import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../utils/const.dart';

Widget storagePercentWidget(int totalStorage, int usedStorage) => Container(
      height: 13.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${usedStorage} GB / $totalStorage GB",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  )),
              Text("Used Storage",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  )),
            ],
          ),
          CircularPercentIndicator(
            animateFromLastPercent: true,
            animation: true,
            animationDuration: 1200,
            radius: 31.0,
            lineWidth: 5.0,
            percent: usedStorage / totalStorage,
      
            progressColor: orange,
            backgroundColor: orage2,
          )
        ],
      ),
    );

Widget fileTypeWidget(String type, String size, String iconPath, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Container(
            height: 20.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: color == orange ? orange.withOpacity(0.8) : color,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type,
                      style: TextStyle(
                        color: color == yellow ? Colors.black : Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(size,
                      style: TextStyle(
                        color: color == orange
                            ? Colors.black.withOpacity(0.5)
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: -50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(iconPath,
                  height: 20.h, width: 30.w, fit: BoxFit.contain),
            ),
          )
        ],
      ),
    ),
  );
}

Widget subtitle(FileSystemEntity entity) {
  return FutureBuilder<FileStat>(
    future: entity.stat(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (entity is File) {
          int size = snapshot.data!.size;

          return Text(
            FileManager.formatBytes(size),
          );
        }
        return Text(
          "${snapshot.data!.modified}".substring(0, 10),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        );
      } else {}
      return const Text("");
    },
  );
}


