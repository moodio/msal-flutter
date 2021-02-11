abstract class MethodChannelAbstract{
  Future<T> invokeMethod<T>(String method, [ dynamic arguments ]);
}