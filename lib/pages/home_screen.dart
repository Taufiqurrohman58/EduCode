import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import 'widgets/animated_card.dart';
import 'widgets/pressable_circle_icon.dart';
import './db/db_hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  /// TEXT DENGAN STROKE
  Widget strokeText({
    required String text,
    required String fontFamily,
    required double fontSize,
    required Color textColor,
    required double strokeWidth,
  }) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.white,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  /// ICON BULAT
  Widget circleIcon({
    required String asset,
    required Color bgColor,
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: iconSize,
          height: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }

  /// PROGRESS BAR
  Widget progressBar({
    required double value,
    required double max,
    required String text,
    required Color iconColor,
    required String icon,
    required double Function(double) w,
    required double Function(double) h,
    required double Function(double) sp,
  }) {
    double progressWidth = (value / max) * w(100);

    /// BIAR TIDAK OVERFLOW
    if (progressWidth > w(100)) {
      progressWidth = w(100);
    }

    return Row(
      children: [
        Container(
          width: w(24),
          height: h(26),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(w(5)),
          ),
          child: Padding(
            padding: EdgeInsets.all(w(2)),
            child: Image.asset(
              icon,
              fit: BoxFit.contain,
            ),
          ),
        ),

        SizedBox(width: w(4)),

        Stack(
          children: [
            /// BACKGROUND BAR
            Container(
              width: w(100),
              height: h(11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(w(10)),
              ),
            ),

            /// FILL BAR
            Container(
              width: progressWidth,
              height: h(11),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius:
                    BorderRadius.circular(w(10)),
              ),
            ),

            /// TEXT
            SizedBox(
              width: w(100),
              height: h(11),

              child: Align(
                alignment: Alignment.centerRight,

                child: Padding(
                  padding:
                      EdgeInsets.only(right: w(5)),

                  child: Text(
                    text,

                    style: TextStyle(
                      fontSize: sp(8),
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// REFRESH SAAT KEMBALI KE HOME
  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.of(context).size.width / 360;

    /// TOTAL PROGRESS
    int materiProgress =
        DBHive.getTotalMateriProgress();

    int gameProgress =
        DBHive.getTotalGameProgress();

    double w(double size) => size * scale;
    double h(double size) => size * scale;
    double sp(double size) => size * scale;

    return Scaffold(
      backgroundColor: const Color(0xFF0BF498),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              /// BACKGROUND
              Positioned(
                top: h(120),
                left: 0,
                right: 0,

                child: Image.asset(
                  "assets/images/bg_org.png",
                  fit: BoxFit.cover,
                ),
              ),

              /// CONTENT
              Padding(
                padding: EdgeInsets.all(w(20)),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    /// TOP BAR
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            /// PROGRESS MATERI
                            progressBar(
                              value:
                                  materiProgress
                                      .toDouble(),

                              max: 40,

                              text:
                                  "$materiProgress/40",

                              iconColor: Colors.blue,

                              icon:
                                  "assets/images/book.png",

                              w: w,
                              h: h,
                              sp: sp,
                            ),

                            SizedBox(height: h(4)),

                            /// PROGRESS GAME
                            progressBar(
                              value:
                                  gameProgress
                                      .toDouble(),

                              max: 40,

                              text:
                                  "$gameProgress/40",

                              iconColor:
                                  Colors.purple,

                              icon:
                                  "assets/images/winning.png",

                              w: w,
                              h: h,
                              sp: sp,
                            ),
                          ],
                        ),

                        /// BUTTON
                        Column(
                          children: [
                            PressableCircleIcon(
                              size: w(42),
                              iconSize: w(28),

                              asset:
                                  "assets/images/exit.svg",

                              bgColor: Colors.yellow,

                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible:
                                      false,

                                  builder: (
                                    context,
                                  ) {
                                    return Center(
                                      child:
                                          Container(
                                        width:
                                            w(250),

                                        padding:
                                            EdgeInsets.all(
                                          w(16),
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors
                                                  .white,

                                          borderRadius:
                                              BorderRadius.circular(
                                            w(20),
                                          ),
                                        ),

                                        child:
                                            Column(
                                          mainAxisSize:
                                              MainAxisSize.min,

                                          children: [
                                            Text(
                                              "Keluar?",

                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    sp(16),

                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            SizedBox(
                                              height:
                                                  h(
                                                10,
                                              ),
                                            ),

                                            Text(
                                              "Apakah kamu yakin ingin keluar?",

                                              textAlign:
                                                  TextAlign.center,

                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    sp(
                                                  12,
                                                ),
                                              ),
                                            ),

                                            SizedBox(
                                              height:
                                                  h(
                                                15,
                                              ),
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,

                                              children: [
                                                /// BATAL
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey,
                                                  ),

                                                  onPressed:
                                                      () {
                                                    Navigator.pop(
                                                      context,
                                                    );
                                                  },

                                                  child:
                                                      const Text(
                                                    "Tidak",

                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                ),

                                                /// KELUAR
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red,
                                                  ),

                                                  onPressed:
                                                      () {
                                                    SystemNavigator.pop();
                                                  },

                                                  child:
                                                      const Text(
                                                    "Ya",

                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                            SizedBox(height: h(10)),

                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/service',
                                );
                              },

                              child: circleIcon(
                                size: w(35),
                                iconSize: w(24),

                                asset:
                                    "assets/images/service.svg",

                                bgColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: h(45)),

                    /// TITLE
                    Align(
                      alignment:
                          Alignment.centerRight,

                      child: SizedBox(
                        width:
                            MediaQuery.of(context)
                                    .size
                                    .width *
                                0.55,

                        child: Column(
                          children: [
                            strokeText(
                              text: "My First",

                              fontFamily:
                                  "merry-bright",

                              fontSize: sp(16),

                              textColor: Colors.red,

                              strokeWidth: w(4),
                            ),

                            Transform.translate(
                              offset:
                                  Offset(0, -h(14)),

                              child: strokeText(
                                text: "CODING",

                                fontFamily:
                                    "howdybun",

                                fontSize: sp(42),

                                textColor:
                                    const Color(
                                  0xFF4CAF6A,
                                ),

                                strokeWidth:
                                    w(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h(90)),

                    /// BELAJAR CODING
                    AnimatedCard(
                      title: "Belajar Coding",

                      subtitle:
                          "Belajar basic konsep coding",

                      bgImage:
                          "assets/images/bg_green.png",

                      iconPath:
                          "assets/images/ic_books.png",

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/pilih_materi',
                        ).then((_) {
                          refreshPage();
                        });
                      },
                    ),

                    SizedBox(height: h(10)),

                    /// TES KEMAMPUAN
                    AnimatedCard(
                      title: "Tes Kemampuan",

                      subtitle:
                          "Uji kemampuan belajar codingmu",

                      bgImage:
                          "assets/images/bg_blue.png",

                      iconPath:
                          "assets/images/ic_game.png",

                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/pilih_level',
                        ).then((_) {
                          refreshPage();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}