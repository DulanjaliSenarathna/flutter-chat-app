import 'package:chatty/common/entities/msgcontent.dart';
import 'package:flutter/material.dart';

Widget ChatRightList(Msgcontent item) {
  return Container(
    child: Text(item.content!),
  );
}
