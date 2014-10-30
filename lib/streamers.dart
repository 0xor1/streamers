/// Contains mixins to enable classes to emit arbitrary objects via streams
library streamers;

/**
 * Streamers is a modified version of Steven Roose excellent dart-events package and my own eventable package:
 *
 * http://github.com/stevenroose/dart-events
 *
 * Streamers provides the same functionality of dart-events though it is more restrictive in order to provide
 * a simpler interface, mainly by only allowing types to be used for matching streams.
 *
 * It is essentially Eventable modified to use Streams like in dart-events.
 */

import 'dart:async';
@MirrorsUsed(override: "*", symbols: "")
import 'dart:mirrors';

part 'receiver.dart';
part 'emitter.dart';

/// Used to listen for all emitted types.
abstract class All {}

final Map<Type, Map<Type, bool>> _typeMatchMap = new Map<Type, Map<Type, bool>>();

Function _typeMatcher(Type acceptedType) => (obj){
  Type objType = obj.runtimeType;
  return acceptedType == objType || _isSubtype(objType, acceptedType);
};

bool _isSubtype(Type objType, Type acceptedType){
  Map<Type, bool> innerAcceptanceMap = _typeMatchMap[objType];
  if(innerAcceptanceMap == null){
    _typeMatchMap[objType] = innerAcceptanceMap = new Map<Type, bool>();
  }
  bool isSubtype = innerAcceptanceMap[acceptedType];
  if(isSubtype == null){
    innerAcceptanceMap[acceptedType] = isSubtype = reflectType(objType).isSubtypeOf(reflectType(acceptedType));
  }
  return isSubtype;
}