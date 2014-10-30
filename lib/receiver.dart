/**
 * Author: Daniel Robinson  http://github.com/0xor1
 */

part of streamers;

/// A convenience mixin class to assist in managing stream subscriptions.
class Receiver {
  Map<Emitter, Map<Type, Set<StreamSubscription>>> _subsByTypeByEmitter;
  Map<Type, Map<Emitter, Set<StreamSubscription>>> _subsByEmitterByType;

  /// listens to [emitter]s [Stream] of [type] with [handler].
  void listen(Emitter emitter, Type type, void handler(obj)) {
    _initialiseIndexes(emitter, type);
    var sub = emitter.on(type).listen(handler);
    _subsByTypeByEmitter[emitter][type].add(sub);
    _subsByEmitterByType[type][emitter].add(sub);
  }

  void _initialiseIndexes(Emitter emitter, Type type) {
    if (_subsByTypeByEmitter == null) {
      _subsByTypeByEmitter = new Map<Emitter, Map<Type, Set<StreamSubscription>>>();
    }
    if (_subsByTypeByEmitter[emitter] == null) {
      _subsByTypeByEmitter[emitter] = new Map<Type, Set<StreamSubscription>>();
      _subsByTypeByEmitter[emitter][type] = new Set<StreamSubscription>();
    }
    if (_subsByEmitterByType == null) {
      _subsByEmitterByType = new Map<Type, Map<Emitter, Set<StreamSubscription>>>();
    }
    if (_subsByEmitterByType[type] == null) {
      _subsByEmitterByType[type] = new Map<Emitter, Set<StreamSubscription>>();
      _subsByEmitterByType[type][emitter] = new Set<StreamSubscription>();
    }
  }

  ///  Cancels all the [StreamSubscription]s to the [emitter]s [Stream] of [type].
  void ignoreTypeFromEmitter(Emitter emitter, Type type){
    if (_subsByTypeByEmitter != null && _subsByTypeByEmitter[emitter] != null && _subsByTypeByEmitter[emitter][type] != null) {
      _subsByTypeByEmitter[emitter][type].forEach((sub) => sub.cancel());
      _subsByTypeByEmitter[emitter].remove(type);
      _subsByEmitterByType[type].remove(emitter);
      if (_subsByTypeByEmitter[emitter].length == 0){
        _subsByTypeByEmitter.remove(emitter);
        _subsByEmitterByType.remove(type);
      }
    }
  }

  /// Cancels all [StreamSubscription]s to [Stream]s of [type].
  void ignoreType(Type type){
    if (_subsByEmitterByType != null && _subsByEmitterByType[type] != null) {
      var subsByEmitter = _subsByEmitterByType[type];
      while (subsByEmitter.isNotEmpty){
        ignoreTypeFromEmitter(subsByEmitter.keys.first, type);
      }
    }
  }

  /// Cancels all [StreamSubscription]s to [Stream]s from [emitter].
  void ignoreEmitter(Emitter emitter){
    if (_subsByTypeByEmitter != null && _subsByTypeByEmitter[emitter] != null) {
      var subsByType = _subsByTypeByEmitter[emitter];
      while (subsByType.isNotEmpty){
        ignoreTypeFromEmitter(emitter, subsByType.keys.first);
      }
    }
  }

  /// Cancels all [StreamSubscription]s this object is responsible for.
  void ignoreAll() {
    if (_subsByTypeByEmitter != null){
      while (_subsByTypeByEmitter.isNotEmpty) {
        ignoreEmitter(_subsByTypeByEmitter.keys.first);
      }
    }
  }
}