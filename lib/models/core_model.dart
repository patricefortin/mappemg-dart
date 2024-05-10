import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart';
import '../interfaces/i_broadcaster.dart';
import '../mapping/color_mapper.dart';
import '../types/common.dart';
import '../types/in_out_map.dart';
import '../types/time_series.dart';
import '../types/time_series_types.dart';

class CoreModel extends Model {
  String uuid = const Uuid().v4();
  bool isFullMode = kDefaultFullModeEnabled;
  bool isKioskMode = kMdnsMeshEnabled;
  int _currentScreenIndex = kDefaultScreenIndex;
  String _networkAddress = 'not-set-yet';
  AppColor? _lastAppColorReceived;
  Notify? uiNotify;

  String _message = '';
  TimeSeries<double> vibrationTimeSeries = TimeSeries();

  final List<MeshNode> meshNodes = [];

  late InOutMap inOutMap;

  CoreModel() {
    inOutMap = InOutMap(notifyListeners: notifyListeners);
  }

  void setFullMode(bool value) {
    isFullMode = value;
    notifyListeners();
  }

  void toggleFullMode() {
    isFullMode = !isFullMode;
    notifyListeners();
    if (isFullMode == false) {
      uiNotify!("Kiosk Mode enabled. Tap to exit.");
    }
  }

  int get currentScreenIndex => _currentScreenIndex;
  set currentScreenIndex(int value) {
    _currentScreenIndex = value;
    notifyListeners();
  }

  void selectScreenVibrate() {
    currentScreenIndex = kScreenIndexVibration;
  }

  void selectScreenSensor() {
    currentScreenIndex = kScreenIndexSensor;
  }

  void selectScreenMdnsMesh() {
    currentScreenIndex = kScreenIndexMdnsMesh;
  }

  void selectScreenMapping() {
    currentScreenIndex = kScreenIndexMapping;
  }

  void selectScreenAppInfo() {
    currentScreenIndex = kScreenIndexAppInfo;
  }

  void selectScreenSettings() {
    currentScreenIndex = kScreenIndexSettings;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
    notifyListeners();
  }

  String get networkAddress => _networkAddress;

  set networkAddress(String value) {
    _networkAddress = value;
    notifyListeners();
  }

  AppColor? get lastAppColorReceived => _lastAppColorReceived;

  set lastAppColorReceived(AppColor? value) {
    _lastAppColorReceived = value;
    notifyListeners();
  }

  String get title {
    switch (_currentScreenIndex) {
      case kScreenIndexSensor:
        return kScreenIndexSensorLabel;
      case kScreenIndexVibration:
        return kScreenIndexVibrationLabel;
      case kScreenIndexMdnsMesh:
        return kScreenIndexMdnsMeshLabel;
      case kScreenIndexMapping:
        return kScreenIndexMappingLabel;
      case kScreenIndexSettings:
        return kScreenIndexSettingsLabel;
      case kScreenIndexAppInfo:
        return kScreenIndexAppInfoLabel;
      default:
        break;
    }
    return '';
  }

  void addToVibrationTimeSeries(TimeSeriesItem<double> item) {
    vibrationTimeSeries.add(item);
    notifyListeners();
  }

  void addMeshNode(MeshNode client) {
    meshNodes.add(client);
    notifyListeners();
  }

  void removeMeshNode(String uuid) async {
    meshNodes.removeWhere((client) => client.uuid == uuid);
    notifyListeners();
  }

  List<String> findMeshUuidsForAddressPort(InternetAddress address, int port) {
    return meshNodes
        .where((element) => element.address == address && element.port == port)
        .map((element) => element.uuid)
        .toList();
  }
}
