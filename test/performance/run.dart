import 'package:emitters/emitters.dart' as em;
import 'package:streamers/streamers.dart' as st;
import 'package:events/events.dart' as ev;
import 'dart:async';

abstract class TestInterface{int val;}
class A implements TestInterface{int val;}
class B extends A{}
class C extends B{}
class D extends C{}
class E extends D{}
class F extends E{}
class G extends F{}
class H extends G{}
class I extends H{}
class J extends I{}
class K extends J{}
class L extends K{}
class M extends L{}
class N extends M{}
class O extends N{}
class P extends O{}
class Q extends P{}
class R extends Q{}
class S extends R{}
class T extends S{}
class U extends T{}
class V extends U{}
class W extends V{}
class X extends W{}
class Y extends X{}
class Z extends Y{}
class DoesntInherit{int val;}
class GenericsA<T>{int val;}
class GenericsB<T> extends GenericsA<T>{}

void main() {
  /**
   * configure test run with the following variables
   */
  int numOfObjToEmit = 100000;
  int numOfDumbSubs = 200;
  Function emitObj = () => new A();
  Type typeToListenTo = A;
  /**
   * End of config variables.
   */

  executeEmittersPerformanceTest(numOfObjToEmit, numOfDumbSubs, emitObj, typeToListenTo)
  .then((_){
    executeStreamersPerformanceTest(numOfObjToEmit, numOfDumbSubs, emitObj, typeToListenTo)
    .then((_){
      executeEventsPerformanceTest(numOfObjToEmit, numOfDumbSubs, emitObj, typeToListenTo);
    });
  });
}

Future executeEmittersPerformanceTest(int numOfObjToEmit, int numOfDumbSubs, Function emitObj, Type typeToListenTo){
  Completer completer = new Completer();
  Stopwatch stopwatch = new Stopwatch();
  em.Emitter emitter = new em.Emitter();
  var dumbHandler = (obj){};
  var actualHandler = (obj){
    if(obj.data.val == numOfObjToEmit - 1){
      stopwatch.stop();
      print('Emitters lib: Emitting $numOfObjToEmit ${emitObj().runtimeType} whilst listening to $typeToListenTo, by $numOfDumbSubs handlers took: ${stopwatch.elapsed}');
      if(!completer.isCompleted) completer.complete();
    }
  };

  // subscribe handlers
  emitter.on(em.All, actualHandler);
  for(var i = 0; i < numOfDumbSubs; i++){
    emitter.on(typeToListenTo, dumbHandler);
  }

  // emit objects and start timing
  stopwatch.start();
  for(var i = 0; i < numOfObjToEmit; i++){
    emitter.emit(emitObj()..val = i);
  }

  return completer.future;
}

Future executeStreamersPerformanceTest(int numOfObjToEmit, int numOfDumbSubs, Function emitObj, Type typeToListenTo){
  Completer completer = new Completer();
  Stopwatch stopwatch = new Stopwatch();
  st.Emitter emitter = new st.Emitter();
  var dumbHandler = (obj){};
  var actualHandler = (obj){
    if(obj.val == numOfObjToEmit - 1){
      stopwatch.stop();
      print('Streamers lib: Emitting $numOfObjToEmit ${emitObj().runtimeType} whilst listening to $typeToListenTo, by $numOfDumbSubs handlers took: ${stopwatch.elapsed}');
      if(!completer.isCompleted) completer.complete();
    }
  };

  // subscribe handlers
  emitter.on(st.All).listen(actualHandler);
  for(var i = 0; i < numOfDumbSubs; i++){
    emitter.on(typeToListenTo).listen(dumbHandler);
  }

  // emit objects and start timing
  stopwatch.start();
  for(var i = 0; i < numOfObjToEmit; i++){
    emitter.emit(emitObj()..val = i);
  }

  return completer.future;
}

Future executeEventsPerformanceTest(int numOfObjToEmit, int numOfDumbSubs, Function emitObj, Type typeToListenTo){
  Completer completer = new Completer();
  Stopwatch stopwatch = new Stopwatch();
  ev.Events emitter = new ev.Events();
  var dumbHandler = (obj){};
  var actualHandler = (obj){
    if(obj.val == numOfObjToEmit - 1){
      stopwatch.stop();
      print('Events lib: Emitting $numOfObjToEmit ${emitObj().runtimeType} whilst listening to $typeToListenTo, by $numOfDumbSubs handlers took: ${stopwatch.elapsed}');
      if(!completer.isCompleted) completer.complete();
    }
  };

  // subscribe handlers
  emitter.on(null).listen(actualHandler);
  for(var i = 0; i < numOfDumbSubs; i++){
    emitter.on(typeToListenTo).listen(dumbHandler);
  }

  // emit objects and start timing
  stopwatch.start();
  for(var i = 0; i < numOfObjToEmit; i++){
    emitter.emit(emitObj()..val = i);
  }

  return completer.future;
}
