part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const ACCOUNT = _Paths.ACCOUNT;
  static const COMPLETE_PROFILE = _Paths.COMPLETE_PROFILE;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;
  static const CHANGE_PASSWORD = _Paths.CHANGE_PASSWORD;
  static const NOTIFICATION = _Paths.NOTIFICATION;
  static const MAIN = _Paths.MAIN;
  static const ORDER_DETAIL = _Paths.ORDER_DETAIL;
  static const TERMS_OF_SERVICE = _Paths.TERMS_OF_SERVICE;
  static const PRIVACY_POLICY = _Paths.PRIVACY_POLICY;
  static const ABOUT_APP = _Paths.ABOUT_APP;
  static const CREATE_ORDER = _Paths.CREATE_ORDER;
  static const STORE_DETAIL = _Paths.STORE_DETAIL;
  static const CHECKOUT = _Paths.CHECKOUT;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const ACCOUNT = '/account';
  static const COMPLETE_PROFILE = '/complete-profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const CHANGE_PASSWORD = '/change-password';
  static const NOTIFICATION = '/notification';
  static const MAIN = '/main';
  static const ORDER_DETAIL = '/order-detail';
  static const TERMS_OF_SERVICE = '/terms-of-service';
  static const PRIVACY_POLICY = '/privacy-policy';
  static const ABOUT_APP = '/about-app';
  static const CREATE_ORDER = '/create-order';
  static const STORE_DETAIL = '/store-detail';
  static const CHECKOUT = '/checkout';
}