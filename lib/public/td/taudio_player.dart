import 'package:taudio/taudio.dart';

import '../../taudio_platform_interface.dart';

class TaudioPlayer
{
  TaudioContext _context = TaudioPlatform.instance.newContext();

  /* ctor */ TaudioPlayer()
  {
  }
}