
import 'package:chatty/pages/profile/controller.dart';
import 'package:chatty/pages/profile/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildProfilePhoto(controller,context),
                  bulidName(controller,(value) {
      controller.state.profile_detail.value.name = value;
    },controller.state.profile_detail.value.name??""),
                  bulidDescription(controller, (value) {
      controller.state.profile_detail.value.description = value;
    },controller.state.profile_detail.value.description??"Enter a description"),
                  buildCompleteBtn(controller),
                  buildLogOutBtn(controller)
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
