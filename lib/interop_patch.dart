// This file patches the JS interop functionality needed by firebase_auth_web
// It should be imported before any Firebase Auth imports

import 'dart:js' as js;
import 'dart:async';

// The PromiseJsImpl type used by firebase_auth_web
class PromiseJsImpl<T> {
  final js.JsObject _jsPromise;
  
  PromiseJsImpl._(this._jsPromise);
  
  factory PromiseJsImpl(Function executor) {
    final jsExecutor = js.allowInterop((resolve, reject) {
      executor(
        js.allowInterop((value) => resolve(value)),
        js.allowInterop((error) => reject(error)),
      );
    });
    
    return PromiseJsImpl._(js.JsObject(js.context['Promise'], [jsExecutor]));
  }
  
  PromiseJsImpl then(Function onFulfilled, [Function? onRejected]) {
    final jsFulfilled = js.allowInterop((value) => onFulfilled(value));
    final jsRejected = onRejected != null ? js.allowInterop((error) => onRejected(error)) : null;
    
    final result = _jsPromise.callMethod('then', [jsFulfilled, jsRejected]);
    return PromiseJsImpl._(result);
  }
  
  PromiseJsImpl catchError(Function onRejected) {
    final jsRejected = js.allowInterop((error) => onRejected(error));
    final result = _jsPromise.callMethod('catch', [jsRejected]);
    return PromiseJsImpl._(result);
  }
}

// Helper function to handle Promise conversions
dynamic handleThenable(dynamic promise) {
  if (promise is! PromiseJsImpl) {
    // Convert JS promise to PromiseJsImpl if needed
    if (promise is js.JsObject) {
      promise = PromiseJsImpl._(promise);
    }
  }
  
  Completer completer = Completer();
  
  if (promise is PromiseJsImpl) {
    promise.then(
      (value) => completer.complete(dartify(value)),
      (error) => completer.completeError(dartify(error))
    );
  } else {
    // Handle non-promise values
    completer.complete(promise);
  }
  
  return completer.future;
}

// Convert JS objects to Dart objects
dynamic dartify(dynamic jsObject) {
  if (jsObject == null) return null;
  
  if (jsObject is js.JsObject) {
    if (js.context['Array'].callMethod('isArray', [jsObject]) == true) {
      // Convert JS array to Dart List
      final length = jsObject['length'] as int;
      final result = <dynamic>[];
      for (var i = 0; i < length; i++) {
        result.add(dartify(jsObject[i]));
      }
      return result;
    } else {
      // Convert JS object to Dart Map
      final result = <String, dynamic>{};
      final keys = js.context['Object'].callMethod('keys', [jsObject]);
      final keyLength = keys['length'] as int;
      for (var i = 0; i < keyLength; i++) {
        final key = keys[i] as String;
        result[key] = dartify(jsObject[key]);
      }
      return result;
    }
  }
  
  // Primitive types are already converted by dart:js
  return jsObject;
}

// Convert Dart objects to JS objects
dynamic jsify(dynamic dartObject) {
  if (dartObject == null) return null;
  
  if (dartObject is Map) {
    final result = js.JsObject(js.context['Object']);
    dartObject.forEach((key, value) {
      result[key.toString()] = jsify(value);
    });
    return result;
  } else if (dartObject is Iterable) {
    final result = js.JsArray();
    for (final item in dartObject) {
      result.add(jsify(item));
    }
    return result;
  }
  
  // Primitive types can be passed as-is
  return dartObject;
} 