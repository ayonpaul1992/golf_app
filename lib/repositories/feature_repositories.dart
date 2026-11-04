import 'package:http/http.dart' as http;
import '../models/api_envelope.dart';
import 'customer_api_repository.dart';

// Each repository owns its endpoint and request contract. Screens retain form,
// selection and navigation state; transport, credentials and decoding live here.
class AuthRepository {
  AuthRepository({CustomerApiRepository? api})
      : api = api ?? CustomerApiRepository();
  final CustomerApiRepository api;
  Future<ApiEnvelope> login(Map<String, dynamic> payload, String course) =>
      api.request('POST', 'auth/customer-login',
          query: {'golfCourseCode': course},
          data: payload,
          authenticated: false);
  Future<ApiEnvelope> forgotPassword(Map<String, dynamic> payload) =>
      api.request('POST', 'auth/password/forgot',
          query: {'role': 'customer'}, data: payload, authenticated: false);
  Future<ApiEnvelope> resetPassword(Map<String, dynamic> payload) =>
      api.request('PUT', 'auth/password',
          query: {'role': 'customer'}, data: payload, authenticated: false);
  Future<ApiEnvelope> signUp(Map<String, dynamic> payload) =>
      api.request('POST', 'auth/sign-up', data: payload, authenticated: false);
  Future<ApiEnvelope> pageSettings(String course) =>
      api.request('GET', 'pageSettings/$course', authenticated: false);
}

class CheckoutRepository {
  CheckoutRepository({CustomerApiRepository? api})
      : api = api ?? CustomerApiRepository();
  final CustomerApiRepository api;
  Future<ApiEnvelope> summary() => api.request('GET', 'sales/customer');
  Future<ApiEnvelope> clear() => api
      .request('DELETE', 'sales/clear', query: {'cartState': 'customerCart'});
  Future<ApiEnvelope> pay(Map<String, dynamic> payload) =>
      api.request('POST', 'transaction/payment', data: payload);
  Future<ApiEnvelope> sendOtp(Map<String, dynamic> payload) =>
      api.request('POST', 'transaction/sendOtp', data: payload);
}

class GiftCardRepository {
  GiftCardRepository({CustomerApiRepository? api})
      : api = api ?? CustomerApiRepository();
  final CustomerApiRepository api;
  Future<ApiEnvelope> templates() =>
      api.request('GET', 'template/giftcards/customer');
  Future<ApiEnvelope> customerByPhone(String phone) => api
      .request('GET', 'customer/email-or-phone', query: {'phoneNumber': phone});
  Future<ApiEnvelope> customerByEmail(String email) =>
      api.request('GET', 'customer/email-or-phone', query: {'email': email});
  Future<ApiEnvelope> purchase(Map<String, dynamic> payload) =>
      api.request('POST', 'giftCard/purchase', data: payload);
}

class BookingRepository {
  BookingRepository({CustomerApiRepository? api})
      : api = api ?? CustomerApiRepository();
  final CustomerApiRepository api;
  Future<ApiEnvelope> upcoming() =>
      api.request('GET', 'teesheet/myBookings', query: {
        'bookingStatus': 'Booked',
        'page': '1',
        'limit': '1',
        'isDashboard': 'true'
      });
  Future<ApiEnvelope> players(String course, String date, String time) =>
      api.request('GET', 'customer/players',
          query: {'golfCourse': course, 'date': date, 'time': time});
  Future<ApiEnvelope> book(Map<String, dynamic> payload) =>
      api.request('POST', 'teesheet/book-teesheet', data: payload);
  Future<ApiEnvelope> cancel(String slotId, Map<String, dynamic> payload) =>
      api.request(
          'DELETE', 'teesheet/myBookings/cancel/${Uri.encodeComponent(slotId)}',
          data: payload);
  Future<ApiEnvelope> facilities(String course) =>
      api.request('GET', 'teesheet/customer-facility',
          query: {'golfCourseCode': course});
  Future<ApiEnvelope> reservationGroups(String teeSheet) =>
      api.request('GET', 'reservationGroup/customer',
          query: {'teeSheet': teeSheet});
  Future<ApiEnvelope> memberships(String? course) =>
      api.request('GET', 'customer/myMembership',
          query: {'golfCourse': '$course'});
}

class ProfileRepository {
  ProfileRepository({CustomerApiRepository? api})
      : api = api ?? CustomerApiRepository();
  final CustomerApiRepository api;
  Future<ApiEnvelope> profile() => api.request('GET', 'customer/myProfile');
  Future<ApiEnvelope> deleteAccount(Map<String, dynamic> payload) =>
      api.request('DELETE', 'customer/delete', data: payload);
  Future<http.StreamedResponse> upload(http.MultipartRequest request) =>
      api.client.send(request);
  Future<ApiEnvelope> postalCode(String code) async =>
      ApiEnvelope(await api.client.get(
          Uri.parse('http://api.geonames.org/postalCodeLookupJSON').replace(
              queryParameters: {
            'postalcode': code,
            'country': 'US',
            'username': 'tuhinkapri'
          })));
}

// Shared instances own their clients for the application's lifetime.
final authRepository = AuthRepository();
final checkoutRepository = CheckoutRepository();
final giftCardRepository = GiftCardRepository();
final bookingRepository = BookingRepository();
final profileRepository = ProfileRepository();
