import 'package:chatty/pages/frame/welcome/index.dart';
import 'package:chatty/pages/frame/sign_in/index.dart';
import 'package:chatty/pages/message/chat/index.dart';
import 'package:chatty/pages/message/voicecall/index.dart';
import 'package:chatty/pages/message/videocall/index.dart';

import 'package:chatty/pages/message/index.dart';
import 'package:chatty/pages/profile/index.dart';
import 'package:chatty/pages/contact/index.dart';

import 'package:flutter/material.dart';
import 'package:chatty/common/middlewares/middlewares.dart';

import 'package:get/get.dart';

import 'routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  static final List<GetPage> routes = [
    // No need to log in
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),

    GetPage(
      name: AppRoutes.SIGN_IN,
      page: () => const SignInPage(),
      binding: SignInBinding(),
    ),
/*
    // Login required
    // GetPage(
    //   name: AppRoutes.Application,
    //   page: () => ApplicationPage(),
    //   binding: ApplicationBinding(),
    //   middlewares: [
    //     RouteAuthMiddleware(priority: 1),
    //   ],
    // ),

    // Latest route
    GetPage(name: AppRoutes.EmailLogin, page: () => EmailLoginPage(), binding: EmailLoginBinding()),
    GetPage(name: AppRoutes.Register, page: () => RegisterPage(), binding: RegisterBinding()),
    GetPage(name: AppRoutes.Forgot, page: () => ForgotPage(), binding: ForgotBinding()),
    GetPage(name: AppRoutes.Phone, page: () => PhonePage(), binding: PhoneBinding()),
    GetPage(name: AppRoutes.SendCode, page: () => SendCodePage(), binding: SendCodeBinding()),
    */
    // front page
    GetPage(
        name: AppRoutes.Contact,
        page: () => const ContactPage(),
        binding: ContactBinding()),

    //Message page
    GetPage(
      name: AppRoutes.Message,
      page: () => const MessagePage(),
      binding: MessageBinding(),
      middlewares: [
        RouteAuthMiddleware(priority: 1),
      ],
    ),

    //profile section
    GetPage(
        name: AppRoutes.Profile,
        page: () => const ProfilePage(),
        binding: ProfileBinding()),

    //chat detail
    GetPage(
        name: AppRoutes.Chat,
        page: () => const ChatPage(),
        binding: ChatBinding()),
/*
    GetPage(name: AppRoutes.Photoimgview, page: () => PhotoImgViewPage(), binding: PhotoImgViewBinding()),
    */
    GetPage(
        name: AppRoutes.VoiceCall,
        page: () => const VoiceCallPage(),
        binding:
            VoiceCallBinding()), 
    GetPage(name: AppRoutes.VideoCall, page: () => const VideoCallPage(), binding: VideoCallBinding()),
  ];
}
