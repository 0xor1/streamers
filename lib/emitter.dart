part of streamers;

/// A mixin class to enable any class to act as a generic emitter of objects.
class Emitter {

  final StreamController _controller = new StreamController.broadcast();
  final Map<Type, Stream> _streamCache = new Map<Type, Stream>();

  /**
  * Emit an object.
  *
  *     emit(new Foo());
  *
  * Will send the new Foo object down the stream returned by `on(Foo)`.
  */
  void emit(obj) => _controller.add(obj);

  /// Get the stream of [type].
  Stream on(Type type){
    var stream = _streamCache[type];
    if(stream == null){
      StreamController controller = new StreamController.broadcast();
      _streamCache[type] = stream = type == All? _controller.stream: controller.stream;
      if(type != All){
        _controller.stream.where(_typeMatcher(type)).listen(controller.add, onError: controller.addError, onDone: controller.close);
      }
    }
    return stream;
  }
}