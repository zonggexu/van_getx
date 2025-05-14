// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:words/utils/Log.dart';
//
// class User {
//   String accessToken;
//   String shopId;
//   String type;
//   String refreshToken;
//
//   User({
//     required this.accessToken,
//     required this.shopId,
//     required this.type,
//     required this.refreshToken,
//   });
// }
//
// class Global {
//   static late User loginUser;
// }
//
// class ApiClient {
//   static final BaseOptions _defaultOptions =
//       BaseOptions(baseUrl: 'https://yourserveraddress', headers: {'tenant-id': 1});
//   late final Dio _httpClient;
//   late final Dio _tokenDio;
//   late final Function(Map)? refreshTokenSuccess;
//
//   Dio get httpClient => _httpClient;
//
//   /// Creates an [ApiClient] with default options.
//   ApiClient({this.refreshTokenSuccess}) {
//     _httpClient = Dio(_defaultOptions);
//     _tokenDio = Dio(_defaultOptions);
//     _tokenDio.interceptors.add(TokenInterceptors());
//     _tokenDio.interceptors.add(LogInterceptor());
//     _httpClient.interceptors.add(LogInterceptor());
//     _httpClient.interceptors
//         .add(AuthInterceptor(tokenDio: _tokenDio, refreshTokenSuccess: refreshTokenSuccess!));
//     (_httpClient.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
//       client.badCertificateCallback = (cert, host, port) {
//         return true; // 忽略证书验证
//       };
//     };
//     (_tokenDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
//       client.badCertificateCallback = (cert, host, port) {
//         return true; // 忽略证书验证
//       };
//     };
//   }
//
//   @override
//   String toString() {
//     return "ApiClient(_httpClient.options.headers['Authorization']: ${_httpClient.options.headers['Authorization']})";
//   }
// }
//
// /// TokenInterceptors定义一个Token拦截器，在onRequest中将Token设置给每个请求的接口，为下面的AuthInterceptor做准备。
// class TokenInterceptors extends Interceptor {
//   TokenInterceptors();
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     User? user = Global.loginUser;
//     // set request header
//     if (user != null) {
//       options.headers['Authorization'] = 'Bearer ${user.accessToken}';
//       options.headers['shop-id'] = user.shopId;
//       options.headers['staff-type'] = user.type;
//     }
//     handler.next(options);
//   }
// }
//
// /// AuthInterceptor正常访问接口的拦截器，在onRequest中依将给每个需要认证的接口请求头中携带AccessToken。
// class AuthInterceptor extends QueuedInterceptorsWrapper {
//   final Dio tokenDio;
//   final int _tokenExpiredCode = 401;
//   final Function(Map)? refreshTokenSuccess;
//
//   AuthInterceptor({required this.tokenDio, this.refreshTokenSuccess});
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     User? user = Global.loginUser;
//     // set request header
//     if (user != null) {
//       options.headers['Authorization'] = 'Bearer ${user.accessToken}';
//       options.headers['shop-id'] = user.shopId;
//       options.headers['staff-type'] = user.type;
//     }
//     handler.next(options);
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) async {
//     if (response.data['code'] == _tokenExpiredCode) {
//       Dlog('${response.requestOptions.path} not have auth need refresh token');
//       bool isAuth = await refreshToken();
//
//       Dlog('refresh token success!');
//       if (isAuth) {
//         Response retryResponse = await _retry(response.requestOptions);
//         Dlog('retry path: ${response.requestOptions.path}');
//         Dlog('retry response: ${retryResponse.data.toString()}');
//         handler.resolve(retryResponse);
//       }
//     } else {
//       handler.next(response);
//     }
//   }
//
//   Future<bool> refreshToken() async {
//     User? user = Global.loginUser;
//     if (user == null) return false;
//     Dlog("refresh token start");
//     Map<String, dynamic> params = {"refreshToken": user?.refreshToken};
//     Response response = await tokenDio.get('/refresh-token-v2', queryParameters: params);
//     if (response.data['code'] == 0) {
//       // update local token
//       if (refreshTokenSuccess != null) {
//         refreshTokenSuccess!(response.data);
//       }
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   Future<bool> makeToken() async {
//     User? user = Global.loginUser;
//     if (user == null) return false;
//     Dlog("refresh token start");
//     Map<String, dynamic> params = {"refreshToken": user?.refreshToken};
//     Response response = await tokenDio.get('/refresh-token-v2', queryParameters: params);
//     if (response.statusCode == 401) {
//       // update local token
//       if (refreshTokenSuccess != null) {
//         refreshTokenSuccess!(response.data);
//       }
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
//     return tokenDio.request<dynamic>(requestOptions.path);
//   }
// }
