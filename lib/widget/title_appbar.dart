import 'package:babyaid/provider/notificaciones_provider.dart';
import 'package:babyaid/screens/home.dart';
import 'package:babyaid/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class TitleAppbar extends StatefulWidget {
  const TitleAppbar({super.key});

  @override
  State<TitleAppbar> createState() => _TitleAppbarState();
}

class _TitleAppbarState extends State<TitleAppbar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Iconsax.arrow_left_copy),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 34, 0, 0),
              child: Image.asset('assets/logo-blanco.png', scale: 2.8),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.notification_bing_copy),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Consumer<NotificacionesProvider>(
                    builder: (context, notificacionesProvider, child) {
                      return Visibility(
                        visible: notificacionesProvider.totalNoLeidas > 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          alignment: Alignment.center,
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            '${notificacionesProvider.totalNoLeidas}',
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
