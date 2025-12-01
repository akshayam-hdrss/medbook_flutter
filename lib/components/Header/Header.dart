// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:medbook/pages/profile.dart';

// class Header extends StatelessWidget {
//   const Header({super.key});

//   void _openSideMenu(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Align(
//           alignment: Alignment.centerLeft,
//           child: FractionallySizedBox(
//             widthFactor: 0.7,
//             child: Material(
//               borderRadius: const BorderRadius.only(
//                 topRight: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//               color: Colors.white,
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(vertical: 50),
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.home, color: Colors.deepOrange),
//                     title: const Text('Home'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/HomePage');
//                     },
//                   ),

//                   ListTile(
//                     leading: const Icon(
//                       Icons.volunteer_activism,
//                       color: Colors.deepOrange,
//                     ),
//                     title: const Text('Charities'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/charities');
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(
//                       Icons.local_offer,
//                       color: Colors.deepOrange,
//                     ),
//                     title: const Text('Offers'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/offers');
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(
//                       FontAwesomeIcons.blog,
//                       color: Colors.deepOrange,
//                     ),
//                     title: const Text('Blogs'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/Blogs');
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(
//                       FontAwesomeIcons.calendar,
//                       color: Colors.deepOrange,
//                     ),
//                     title: const Text('Events'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/events');
//                     },
//                   ),

//                   ListTile(
//                     leading: const Icon(
//                       Icons.article,
//                       color: Colors.deepOrange,
//                     ),
//                     title: const Text('Terms and Conditions'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/termsandconditions');
//                     },
//                   ),

//                   ListTile(
//                     leading: const Icon(
//                       Icons.contact_mail,
//                       color: Colors.deepOrange,
//                     ),
//                     title: const Text('Contact Us'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/contact');
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     final statusBarHeight = MediaQuery.of(context).padding.top;

//     return Container(
//       padding: EdgeInsets.only(
//         top: statusBarHeight + 10, // 👈 adds safe top spacing
//         left: 16,
//         right: 16,
//         bottom: 20,
//       ),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color.fromARGB(255, 199, 33, 8),
//             Color.fromARGB(255, 199, 33, 8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(35),
//           bottomRight: Radius.circular(35),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.menu, color: Colors.white, size: 28),
//             onPressed: () => _openSideMenu(context),
//           ),
//           const Text(
//             'Medbook',
//             style: TextStyle(
//               fontFamily: 'Impact',
//               fontSize: 40,
//               color: Colors.white,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(
//               Icons.account_circle,
//               color: Colors.white,
//               size: 35,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfilePage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/pages/Quiz/Stage_page.dart'; // Import StagePage
import 'package:medbook/pages/profile.dart'; // Import ProfilePage

class Header extends StatelessWidget {
  const Header({super.key});

  void _openSideMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.7,
            child: Material(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 50),
                children: [
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.deepOrange),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/HomePage');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.quiz, color: Colors.deepOrange),
                    title: const Text('Quiz'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StagePage(), // Navigate to StagePage
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.volunteer_activism,
                      color: Colors.deepOrange,
                    ),
                    title: const Text('Charities'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/charities');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.local_offer,
                      color: Colors.deepOrange,
                    ),
                    title: const Text('Offers'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/offers');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.blog,
                      color: Colors.deepOrange,
                    ),
                    title: const Text('Blogs'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Blogs');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      FontAwesomeIcons.calendar,
                      color: Colors.deepOrange,
                    ),
                    title: const Text('Events'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/events');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.article,
                      color: Colors.deepOrange,
                    ),
                    title: const Text('Terms and Conditions'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/termsandconditions');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.contact_mail,
                      color: Colors.deepOrange,
                    ),
                    title: const Text('Contact Us'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/contact');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: statusBarHeight + 10, // 👈 adds safe top spacing
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 199, 33, 8),
            Color.fromARGB(255, 199, 33, 8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => _openSideMenu(context),
          ),
          const Text(
            'Medbook',
            style: TextStyle(
              fontFamily: 'Impact',
              fontSize: 40,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
