import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

const int kUploadMaxCount = 5;

///自定义占位布局小部件
///也就是替换默认的+号小部件
///[size] - 组件宽高
typedef AddWidgetBuilder = Widget Function(Size size);

///自定义选择菜单
/// [imagePicker] - 用户选择了相册回调函数
/// [cameraPicker] - 用户选择了拍摄回调函数
typedef MenusBuilder =
    Widget Function({
      Function(BuildContext context)? imagePicker,
      Function(BuildContext context)? cameraPicker,
    });

const EdgeInsets bodyPadding = EdgeInsets.all(10);
const radius = Radius.circular(16);

///图片选择组件
class AssetsPicker extends StatefulWidget {
  ///最多可以选择几张图片
  ///
  /// 默认: 9
  final int maxCount;

  /// 是否允许多选
  ///
  /// 默认false
  final bool multiple;

  /// 是否只能用相机拍摄
  ///
  /// 默认ture
  final bool onlyCamera;

  /// 是否允许录像
  ///
  /// 默认ture
  final bool canRecording;

  /// 最大视频录制时长
  /// 默认15秒
  /// 仅在[canRecording]为true时生效
  /// 设为null则不限制时长
  final Duration? maximumRecordingDuration;

  /// 获取图片或视频后的回调
  final void Function(List<File> files)? onCaptured;

  /// 自定义占位小部件
  ///
  ///
  /// 例子
  ///                 addWidgetBuilder: (size) {
  ///                   return SizedBox(
  ///                       width: size.width,
  ///                       height: size.height,
  ///                       child: Center(
  ///                         child: Column(
  ///                           mainAxisAlignment: MainAxisAlignment.center,
  ///                           children: [
  ///                             Icon(Icons.add),
  ///                             SizedBox(height: 2),
  ///                             Text('添加图片'),
  ///                           ],
  ///                         ),
  ///                       ));
  ///                 },
  ///
  ///
  final AddWidgetBuilder? addWidgetBuilder;

  /// 自定义弹出菜单布局
  ///
  /// [Function] - 参数1 - 相册选择方式回调函数
  /// [Function] - 参数2 - 相机拍摄选择模式
  ///
  ///
  /// 例子:
  ///                 menusBuilder: (a,b){
  ///                   return Container(
  ///                     color: Colors.pink,
  ///                     child: SingleChildScrollView(
  ///                       child: Column(children: [
  ///                         TextButton(child: Text('图库选择'),onPressed: () async {
  ///                           await a();
  ///                         },),
  ///                         TextButton(child: Text('相机选择'),onPressed: () async {
  ///                           await b();
  ///                         },)
  ///                       ],)
  ///                     ),
  ///                   );
  ///                 },
  ///
  ///
  final MenusBuilder? menusBuilder;

  const AssetsPicker({
    super.key,
    this.maxCount = kUploadMaxCount,
    this.onlyCamera = false,
    this.multiple = true,
    this.canRecording = true,
    this.maximumRecordingDuration = const Duration(seconds: 15),
    this.menusBuilder,
    this.addWidgetBuilder,
    this.onCaptured,
  });

  @override
  State<AssetsPicker> createState() => _AssetsPickerState();
}

class _AssetsPickerState extends State<AssetsPicker> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => showSelection(),
          child: widget.addWidgetBuilder != null
              ? widget.addWidgetBuilder!.call(
                  Size(constraints.maxWidth, constraints.maxWidth),
                )
              : const _DefaultAddWidget(),
        );
      },
    );
  }

  /// 从相册选择还是直接拍摄
  void showSelection() {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      ),

      // 控制高度显示在安全区域
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewPadding.top,
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: bodyPadding.left,
            top: bodyPadding.top,
            right: bodyPadding.right,
            //控制底部显示在安全区域
            bottom:
                bodyPadding.bottom + MediaQuery.of(context).viewPadding.bottom,
          ),
          child:
              widget.menusBuilder?.call(
                cameraPicker: (context) => _shoot(),
                imagePicker: widget.onlyCamera
                    ? null
                    : (context) {
                        _photoAlbumSelect();
                      },
              ) ??
              _DefaultMenuWidget(
                cameraPicker: (context) => _shoot(),
                imagePicker: widget.onlyCamera
                    ? null
                    : (context) {
                        _photoAlbumSelect();
                      },
              ),
        );
      },
    );
  }

  /// 拍摄图片
  void _shoot() async {
    Navigator.of(context).pop();

    if (!mounted) return;

    AssetEntity? entity = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: CameraPickerConfig(
        enableRecording: widget.canRecording,
        shouldDeletePreviewFile: true,
        enableAudio: false,
        maximumRecordingDuration: widget.maximumRecordingDuration,
        resolutionPreset: ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      ),
    );

    /// 输出图片
    if (entity == null) return;
    widget.onCaptured?.call([(await entity.file)!]);
  }

  /// 去相册选择
  void _photoAlbumSelect() async {
    Navigator.of(context).pop();

    if (!mounted) return;

    List<AssetEntity>? entities = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: widget.multiple ? widget.maxCount : 1,
        requestType: widget.canRecording
            ? RequestType.common
            : RequestType.image,
        // specialPickerType: SpecialPickerType.wechatMoment,
      ),
    );

    if (entities == null) return;

    /// 将[AssetEntity]的file取出
    List<File> files = [];
    for (var entity in entities) {
      File? file = await entity.file;
      if (file != null) {
        /// 检查文件名
        /// 某些情况下，用户从相册中获取的文件没有扩展名
        /// 在上传时，可能会出现问题
        /// 此时需要给文件添加默认扩展名
        final ex = file.extension;
        if (ex.isEmpty) {
          final String suffix = entity.type == AssetType.image
              ? '.jpg'
              : '.mp4';
          file = await file.rename(file.path + suffix);
        }
        files.add(file);
      }
    }
    widget.onCaptured?.call(files);
  }
}

/// 默认的[添加按钮]控件
class _DefaultAddWidget extends StatelessWidget {
  const _DefaultAddWidget();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add, size: 48, color: Colors.grey),
      ),
    );
  }
}

/// 默认的弹出菜单控件
class _DefaultMenuWidget extends StatelessWidget {
  const _DefaultMenuWidget({
    required this.cameraPicker,
    required this.imagePicker,
  });

  final Function(BuildContext context)? cameraPicker;
  final Function(BuildContext context)? imagePicker;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          imagePicker != null
              ? ListTile(
                  title: const Center(child: Text('相册')),
                  onTap: () {
                    imagePicker?.call(context);
                  },
                )
              : Container(),
          ListTile(
            title: const Center(child: Text('去拍摄')),
            onTap: (() {
              cameraPicker?.call(context);
            }),
          ),
        ],
      ),
    );
  }
}

extension FileExtension on File {
  /// 获取文件扩展名
  String get extension {
    final dotIndex = path.lastIndexOf('.');
    final slashIndex = path.lastIndexOf(Platform.pathSeparator);
    if (dotIndex == -1 || slashIndex >= dotIndex) {
      return '';
    }
    return path.substring(dotIndex + 1);
  }
}
