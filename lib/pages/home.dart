import 'package:flutter/material.dart';
import 'package:navi/theme.dart';
import 'package:navi/main.dart';

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Theme.of(context).colorScheme.background,
                      elevation: 0,
                      child: SizedBox(
                        height: 150,
                          child: ListView(
                            children: [
                              SizedBox(
                                height: 16,
                              ),
                              Text('16',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w100,
                                color: Theme.of(context).colorScheme.primary
                              ),
                            ),
                              Text('Poses done this week',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primary
                                ),
                              ),
                            ],
                          ),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Card(
                  //     color: Theme.of(context).colorScheme.primaryContainer,
                  //     elevation: 0,
                  //     child: SizedBox(
                  //       height: 150,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      elevation: 0,
                      child: SizedBox(
                        height: 150,
                        child: ListView(
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Text('74%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w100,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text('Pose accuracy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      splashColor: Theme.of(context).colorScheme.primary,
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        elevation: 0,
                        child: SizedBox(
                          height: 150,
                          child: ListView(
                            children: [
                              SizedBox(
                                height: 40,
                              ),
                              Icon(
                                Icons.color_lens_outlined,
                                size: 50,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text('Edit Colour',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      splashColor: Theme.of(context).colorScheme.onSurface,
                      onTap: () {
                        if(AppTheme.customBrightness == Brightness.dark){
                          AppTheme.customBrightness = Brightness.light;
                          print("let there be LIGHT");
                          print(AppTheme.customBrightness);
                          print(Theme.of(context).brightness);
                        }else{
                          AppTheme.customBrightness = Brightness.dark;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                          );
                          print("come to the DARKSIDE");
                          print(AppTheme.customBrightness);
                          print(Theme.of(context).brightness);
                        }

                        setState(() {
                          AppTheme.customBrightness;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 0,
                        child: SizedBox(
                          height: 150,
                          child: ListView(
                            children: [
                              SizedBox(
                                height: 40,
                              ),
                              Icon(
                                Icons.dark_mode,
                                size: 50,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text('Dark Mode',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        )
      ),
    );
  }
}