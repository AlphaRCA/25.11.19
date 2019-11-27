import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hold/bloc/preferences_provider.dart';
import 'package:hold/storage/storage_provider.dart';

import 'mixpanel_provider.dart';

class DataOverallBloc {
  StreamController<bool> _hasDataController = new StreamController();
  Stream<bool> get hasData => _hasDataController.stream;

  DataOverallBloc() {
    _loadData();
  }

  Future _loadData() async {
    _hasDataController.add(await StorageProvider().doesHaveData());
  }

  Future clearData() async {
    MixPanelProvider().trackEvent(
        "PROFILE", {"Click Clear my data": DateTime.now().toIso8601String()});
    await StorageProvider().clearMyData();
    await PreferencesProvider().saveHighestConversationLevel(1);
    await PreferencesProvider().saveHighestCollectionLevel(1);
    _hasDataController.add(false);
  }

  Future importData() async {
    FileType _pickingType = FileType.CUSTOM;
    String _path;
    try {
      _path = await FilePicker.getFilePath(
          type: _pickingType, fileExtension: "txt");
    } catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (_path == null) return;
    final file = File(_path);
    String text = await file.readAsString();
    print("loaded file");
    await StorageProvider().importFromFile(text);
  }

  Future exportData() async {
    MixPanelProvider().trackEvent(
        "PROFILE", {"Click Export": DateTime.now().toIso8601String()});
    String fileContent = await StorageProvider().exportToFile();
    print("FILE CONTENT: $fileContent");
    try {
      var list = utf8.encode(fileContent);
      final ByteData bytes = ByteData.view(list is Uint8List
          ? list.buffer
          : new Uint8List.fromList(list).buffer);
      await Share.file('reflections', 'reflections.txt',
          bytes.buffer.asUint8List(), 'text/plain');
    } catch (e) {
      print('error: $e');
    }
  }
}
