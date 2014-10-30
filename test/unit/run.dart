/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

library streamers.test.unit;

import 'package:unittest/unittest.dart';
import 'dart:async';
import 'package:streamers/streamers.dart';

abstract class Interface{int val;}
class A implements Interface{int val;}
class B extends A{}
class C{}
class GenericsA<T>{}
class GenericsB<T> extends GenericsA<T>{}
class TestStopwatch extends Stopwatch{}

Emitter emitter1;
Emitter emitter2;
Receiver receiver;

dynamic lastDetectedType;
int typeADetectedCount;
int typeBDetectedCount;
int typeCDetectedCount;

void handler(obj){
  if(obj is A){
    typeADetectedCount++;
  }
  else if(obj is B){
    typeBDetectedCount++;
  }
  else if(obj is C){
    typeCDetectedCount++;
  }
  lastDetectedType = obj;
}

void _setUp(){
  emitter1 = new Emitter();
  emitter2 = new Emitter();
  receiver = new Receiver();

  typeADetectedCount = typeCDetectedCount = 0;

  receiver.listen(emitter1, A, handler);
  receiver.listen(emitter2, C, handler);
}

void _tearDown(){
  emitter1 = emitter2 = receiver = lastDetectedType = null;
  typeADetectedCount = typeCDetectedCount = 0;
}

void main(){
  setUp(_setUp);
  tearDown(_tearDown);
  group('Streamers', (){
    test('Receiver.ignoreAll() cancels all subscriptions.', (){
      receiver.ignoreAll();
      emitter1.emit(new A());
      emitter2.emit(new C());
      Timer.run(expectAsync((){
        expect(typeADetectedCount, equals(0));
        expect(typeCDetectedCount, equals(0));
      }));
    });

    test('calling Receiver cancel methods doesn\'t throw errors when no subscriptions are currently set up.', (){
      var receiver = new Receiver();
      var emitter = new Emitter();
      receiver.ignoreAll();
      receiver.ignoreEmitter(emitter);
      receiver.ignoreType(Object);
      receiver.ignoreTypeFromEmitter(emitter, Object);
      expect(true, equals(true));
    });

    test('Receiver.ignoreType(type) cancels all subscriptions for the specified type.', (){
      receiver.ignoreType(A);
      emitter1.emit(new A());
      emitter2.emit(new C());
      Timer.run(expectAsync((){
        expect(typeADetectedCount, equals(0));
        expect(typeCDetectedCount, equals(1));
      }));
    });

    test('Receiver.ignoreEmitter(emitter) cancels all subscriptions from the specified emitter.', (){
      receiver.ignoreEmitter(emitter1);
      emitter1.emit(new A());
      emitter2.emit(new C());
      Timer.run(expectAsync((){
        expect(typeADetectedCount, equals(0));
        expect(typeCDetectedCount, equals(1));
      }));
    });

    test('ReceiverHandlers are called asynchronously.', (){
      emitter1.emit(new A());
      expect(lastDetectedType, equals(null));
      Timer.run(expectAsync((){
        expect(lastDetectedType.runtimeType, equals(A));
      }));
    });

    test('listening to type All detects all types from an emitter.', (){
      receiver.ignoreAll();
      receiver.listen(emitter1, All, handler);
      emitter1.emit(new A());
      emitter1.emit(new A());
      emitter1.emit(new C());
      emitter2.emit(new C());
      Timer.run(expectAsync((){
        expect(typeADetectedCount, equals(2));
        expect(typeCDetectedCount, equals(1));
      }));
    });

    test('listening to an interface still receives implementations of that interface.', (){
      receiver.ignoreAll();
      receiver.listen(emitter1, Interface, handler);
      emitter1.emit(new A());
      emitter1.emit(new B());
      emitter1.emit(new C());
      Timer.run(expectAsync((){
        expect(typeADetectedCount, equals(2)); // A and B implement Interface
        expect(typeCDetectedCount, equals(0)); // C does not
      }));
    });

    test('listening to a supertype still receives its subtypes.', (){
      receiver.ignoreAll();
      receiver.listen(emitter1, A, handler);
      emitter1.emit(new B());
      Timer.run(expectAsync((){
        expect(typeADetectedCount, equals(1));
      }));
    });

    test('listening to a super generic type still receives implementations of its subtypes. (1)', (){
      receiver.ignoreAll();
      var receivedCount = 0;
      receiver.listen(emitter1, new GenericsA<Stopwatch>().runtimeType, (genASw){receivedCount++;});
      emitter1.emit(new GenericsA<Stopwatch>());
      emitter1.emit(new GenericsA<TestStopwatch>());
      emitter1.emit(new GenericsA<int>());
      Timer.run(expectAsync((){
        expect(receivedCount, equals(2));
      }));
    });

    test('listening to a super generic type still receives implementations of its subtypes. (2)', (){
      receiver.ignoreAll();
      var receivedCount = 0;
      receiver.listen(emitter1, GenericsA, (genASw){receivedCount++;});
      emitter1.emit(new GenericsA<Stopwatch>());
      emitter1.emit(new GenericsA<TestStopwatch>());
      emitter1.emit(new GenericsA<int>());
      Timer.run(expectAsync((){
        expect(receivedCount, equals(3));
      }));
    });
  });
}