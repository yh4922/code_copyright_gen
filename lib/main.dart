import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '软著代码生成',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 文档头部输入框控制器
  late TextEditingController headerInputController;
  /// 文档头部输入框焦点控制器 
  late FocusNode headerInputFocusNode;
  String? headerInputErrorText;

  /// 目录选择框颜色
  Color directoryFocusColor = Colors.grey;
  /// 目录拖动状态
  bool directoryDragging = false;
  /// 选中的目录
  Directory? selectedDirectory;

  /// 代码后缀类型输入控制器
  late TextEditingController codeSuffixInputController;
  /// 代码后缀类型输入控制器焦点控制器 
  late FocusNode codeSuffixInputFocusNode;
  String? codeSuffixErrorText;
  /// 代码后缀类型列表
  List<String> codeSuffix = ['dart'];
  

  @override
  void initState() {
    super.initState();
    headerInputController = TextEditingController(text: '');
    headerInputFocusNode = FocusNode();

    codeSuffixInputController = TextEditingController(text: '');
    codeSuffixInputFocusNode = FocusNode();
  }

  /// 提取选中目录的代码文件
  void startExtractCode () async {
    // 检查输入标题
    if (headerInputController.text.trim().isEmpty) {
      setState(() {headerInputErrorText = '请输入文档头部标题';});
      FocusScope.of(context).requestFocus(headerInputFocusNode);
      return;
    }

    // 检查选中文件夹
    if (selectedDirectory == null) {
      setState(() {directoryFocusColor = Colors.red;});
      BotToast.showText(text: '请选中代码文件夹');
      return;
    }
    
    // 检查代码后缀
    if (codeSuffix.isEmpty) {
      setState(() {codeSuffixErrorText = '至少填写一种代码文件';});
      FocusScope.of(context).requestFocus(codeSuffixInputFocusNode);
      return;
    }
  }

  OutlineInputBorder getOutlineInputBorder (Color color) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: color, width: 2.0),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('生成'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500
          ),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: headerInputController,
                focusNode: headerInputFocusNode,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  labelText: "文档头部标题",
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: "输入文档描述",
                  errorText: headerInputErrorText,
                  prefixIcon: const Icon(Icons.title),
                  border: getOutlineInputBorder(Colors.grey),
                  enabledBorder: getOutlineInputBorder(Colors.grey),
                  errorBorder: getOutlineInputBorder(Colors.red),
                  focusedBorder: getOutlineInputBorder(Colors.blue),
                ),
                onChanged: (val) {
                  setState(() {
                    headerInputErrorText = null;
                  });
                },
              ),
              Stack(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onHover: (e) {
                      setState(() {
                        directoryFocusColor = Colors.blue;
                      });
                    },
                    onExit: (e) {
                      setState(() {
                        directoryFocusColor = Colors.grey;
                      });
                    },
                    child: DropTarget(
                      child: GestureDetector(
                        onTap: () async {
                          var hideLoading = BotToast.showLoading();
                          await Future.delayed(const Duration(milliseconds: 150));
                          FilePicker.platform.getDirectoryPath().then((value) {
                            hideLoading();
                            if (value != null) {
                              setState(() {
                                selectedDirectory = Directory(value);
                              });
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          height: 200, alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(width: 2, color: directoryFocusColor)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.create_new_folder, size: 55,
                                color: directoryFocusColor,
                              ),
                              Text('点击选择，或者拖拽进入', style: TextStyle(color: directoryFocusColor)),
                              selectedDirectory == null 
                              ? const SizedBox() 
                              : Text(selectedDirectory!.path, style: TextStyle(color: directoryFocusColor))
                            ],
                          ),
                        ),
                      ),
                      onDragEntered: (e) {
                        setState(() {
                          directoryFocusColor = Colors.blue;
                          directoryDragging = true;
                        });
                      },
                      onDragExited: (detail) {
                        setState(() {
                          directoryFocusColor = Colors.grey;
                          directoryDragging = false;
                        });
                      },
                      onDragDone: (detail) {
                        // print(detail.urls[0].path);
                        Directory directory = Directory(detail.urls[0].toFilePath());
                        if (!directory.existsSync()) {
                          BotToast.showText(text: '不是一个有效的目录');
                        } else {
                          setState(() {
                            selectedDirectory = directory;
                          });
                        }
                      }
                    ),
                  ),
                  Positioned(
                    top: 13,
                    left: 37,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.white,
                      child: Text(
                        '打开代码文件夹', style: TextStyle(
                          fontSize: 12,
                          color: directoryFocusColor
                        ),
                      ),
                    )
                  ),
                ],
              ),
              TextField(
                controller: codeSuffixInputController,
                focusNode: codeSuffixInputFocusNode,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  labelText: "代码后缀名",
                  labelStyle: const TextStyle(color: Colors.grey),
                  hintText: "输入后回车确认",
                  errorText: codeSuffixErrorText,
                  prefixIcon: const Icon(Icons.code),
                  border: getOutlineInputBorder(Colors.grey),
                  errorBorder: getOutlineInputBorder(Colors.red),
                  enabledBorder: getOutlineInputBorder(Colors.grey),
                  focusedBorder: getOutlineInputBorder(Colors.blue),
                ),
                onSubmitted: (val) {
                  codeSuffixInputController.text = '';
                  if (codeSuffix.contains(val.trim())) {
                    BotToast.showText(text: '已存在后缀名');
                  } else {
                    setState(() {
                      codeSuffix.add(val);
                    });
                  }
                  FocusScope.of(context).requestFocus(codeSuffixInputFocusNode);
                },
              ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 2, color: Colors.grey)
                ),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: [
                    ...codeSuffix.map((suffix) {
                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: Chip(
                          label: Text(suffix),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          deleteIconColor: Colors.black54,
                          onDeleted: () {
                            setState(() {
                              codeSuffix.remove(suffix);
                            });
                          },
                        ),
                      );
                    }).toList(),
                    codeSuffix.isEmpty 
                      ? const Text(' 请输入需要提取代码的文件后缀名', style: TextStyle(color: Colors.grey)) 
                      : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Container(
                  height: 40, alignment: Alignment.center,
                  child: const Text('开始提取代码'),
                ),
                onPressed: startExtractCode,
              )
            ],
          )
        ),
      ),
    );
  }
}
