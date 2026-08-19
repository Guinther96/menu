import 'package:dio/dio.dart';

/// Simple Dio-based API client for the NestJS backend described in the API audit.
/// Methods return decoded JSON (Map / List) — adapt models in the app as needed.
class ApiClient {
  final Dio _dio;

  ApiClient({
    String baseUrl = 'https://backendresto-fwwi.onrender.com',
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // --- Auth ---
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final r = await _dio.post('/auth/register', data: body);
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final r = await _dio.post('/auth/login', data: body);
    return _safeMap(r.data);
  }

  // --- Restaurants ---
  Future<List<dynamic>> getRestaurants() async {
    final r = await _dio.get('/restaurants');
    return _safeList(r.data);
  }

  Future<Map<String, dynamic>> getRestaurantMe() async {
    final r = await _dio.get('/restaurants/me');
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> updateRestaurantMe(
    Map<String, dynamic> body,
  ) async {
    final r = await _dio.put('/restaurants/me', data: body);
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> getRestaurantById(String id) async {
    final r = await _dio.get('/restaurants/$id');
    return _safeMap(r.data);
  }

  Future<List<dynamic>> getRestaurantMenu(String restaurantId) async {
    final r = await _dio.get('/restaurants/$restaurantId/menu');
    return _safeList(r.data);
  }

  // --- Menu ---
  Future<List<dynamic>> getMenu() async {
    final r = await _dio.get('/menu');
    return _safeList(r.data);
  }

  Future<List<dynamic>> getMenuMe() async {
    final r = await _dio.get('/menu/me');
    return _safeList(r.data);
  }

  Future<List<dynamic>> getMenuForRestaurant(String restaurantId) async {
    final r = await _dio.get('/menu/restaurant/$restaurantId');
    return _safeList(r.data);
  }

  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> body) async {
    final r = await _dio.post('/menu', data: body);
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> patchMenuItem(
    String id,
    Map<String, dynamic> body,
  ) async {
    final r = await _dio.patch('/menu/$id', data: body);
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> deleteMenuItem(String id) async {
    final r = await _dio.delete('/menu/$id');
    return _safeMap(r.data);
  }

  // --- Tables ---
  Future<Map<String, dynamic>> getTable(String id) async {
    final r = await _dio.get('/tables/$id');
    return _safeMap(r.data);
  }

  Future<List<dynamic>> getTablesRestaurantMe() async {
    final r = await _dio.get('/tables/restaurant/me');
    return _safeList(r.data);
  }

  Future<Map<String, dynamic>> createTable(Map<String, dynamic> body) async {
    final r = await _dio.post('/tables', data: body);
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> resolveQr(Map<String, dynamic> body) async {
    final r = await _dio.post('/tables/resolve-qr', data: body);
    return _safeMap(r.data);
  }

  // --- Orders ---
  Future<List<dynamic>> getOrders() async {
    final r = await _dio.get('/orders');
    return _safeList(r.data);
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    final r = await _dio.post('/orders', data: body);
    return _safeMap(r.data);
  }

  Future<List<dynamic>> getOrdersRestaurantMe() async {
    final r = await _dio.get('/orders/restaurant/me');
    return _safeList(r.data);
  }

  Future<Map<String, dynamic>> getOrdersRestaurantId(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    final r = await _dio.get(
      '/orders/restaurant/$id',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> getOrderById(String id) async {
    final r = await _dio.get('/orders/$id');
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> patchOrderStatus(
    String id,
    Map<String, dynamic> body,
  ) async {
    final r = await _dio.patch('/orders/$id/status', data: body);
    return _safeMap(r.data);
  }

  // --- Kitchen ---
  Future<List<dynamic>> getKitchenOrdersMe() async {
    final r = await _dio.get('/kitchen/orders/me');
    return _safeList(r.data);
  }

  Future<Map<String, dynamic>> patchKitchenOrderStatus(
    String id,
    Map<String, dynamic> body,
  ) async {
    final r = await _dio.patch('/kitchen/orders/$id/status', data: body);
    return _safeMap(r.data);
  }

  // --- Pairing ---
  Future<Map<String, dynamic>> pairingGenerate(
    Map<String, dynamic> body,
  ) async {
    final r = await _dio.post('/pairing/generate', data: body);
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> pairingConnect(Map<String, dynamic> body) async {
    final r = await _dio.post('/pairing/connect', data: body);
    return _safeMap(r.data);
  }

  Future<Map<String, dynamic>> pairingDelete(String restaurantId) async {
    final r = await _dio.delete('/pairing/restaurant/$restaurantId');
    return _safeMap(r.data);
  }

  // --- Staff ---
  Future<List<dynamic>> getStaff() async {
    final r = await _dio.get('/staff');
    return _safeList(r.data);
  }

  Future<Map<String, dynamic>> createStaff(Map<String, dynamic> body) async {
    final r = await _dio.post('/staff', data: body);
    return _safeMap(r.data);
  }

  Future<void> deleteStaff(String staffUserId) async {
    await _dio.delete('/staff/$staffUserId');
  }

  // --- Utilities ---
  static Map<String, dynamic> _safeMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{'data': data};
  }

  static List<dynamic> _safeList(dynamic data) {
    if (data is List) return data;
    return [data];
  }
}
