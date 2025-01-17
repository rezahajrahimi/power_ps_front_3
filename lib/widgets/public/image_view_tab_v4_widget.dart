import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powerps/helper/public.dart';
import 'package:powerps/helper/responsive.dart';
import 'package:powerps/widgets/public/full_screen_image.dart';
import 'package:powerps/widgets/public/widgets_gridview_widget_v4.dart';
import 'package:path_provider/path_provider.dart';

class CustomImageView extends StatefulWidget {
  const CustomImageView({super.key, required this.imageSrc});
  final String imageSrc;

  @override
  State<CustomImageView> createState() => _CustomImageViewState();
}

class _CustomImageViewState extends State<CustomImageView> {
  final List<Widget> _myList = [];

  @override
  void initState() {
    _retriveData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _myList.isNotEmpty
        ? Column(
            children: [
              SizedBox(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // launchUrl(Uri.parse(widget.imageSrc));
                    // Download image
                    _downloadImage();
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("دانلود رسید"),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: Responsive(
                  mobile: widgetsGridview(
                      childAspectRatio: 3.5,
                      crossAxisCount: 1,
                      context: context,
                      importedList: _myList),
                  tablet: widgetsGridview(
                      context: context,
                      crossAxisCount: 1,
                      childAspectRatio: 5.5,
                      importedList: _myList),
                  desktop: widgetsGridview(
                      importedList: _myList,
                      context: context,
                      // childAspectRatio: 5.5,
                      crossAxisCount: 1),
                ),
              ),
            ],
          )
        : const Opacity(opacity: 1);
  }

  void _retriveData() {
    if (mounted) {
      setState(() {
        try {
          _myList.clear();
          _myList.add(GestureDetector(
            child: CachedNetworkImage(
              imageUrl: widget.imageSrc,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return FullScreenImage(
                  imageUrl: widget.imageSrc,
                  tag: "رسید مشتری",
                );
              }));
            },
          ));
        } catch (e) {
          _myList.add(Container());
        }
      });
    }
  }

  Future<File> _downloadImage() async {
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(widget.imageSrc));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/image.jpg');
    await file.writeAsBytes(bytes);
    httpClient.close();
    if (mounted) {
      showMsg(
          msg: "تصویر رسید در مسیر ${file.path} دانلود شد", context: context);
    }

    return file;
  }
}
