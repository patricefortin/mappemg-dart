import 'dart:io';

import 'package:logger/logger.dart';

import 'constants.dart';

bool isTest = Platform.environment.containsKey('FLUTTER_TEST');

Level getLogLevel() => isTest ? Level.error : kLogLevel;
Logger getLogger() => Logger(level: getLogLevel(), printer: LogfmtPrinter());

bool shouldInitController() => isTest ? false : true;
bool shouldListNetworkInterfaces() => isTest ? false : true;

bool shouldInitBluetooth() => isTest ? false : true;
