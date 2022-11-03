import 'package:flutter/material.dart';
import 'package:navi/pages/camera_view.dart';
import 'package:navi/pages/new_pose.dart';
import 'package:navi/pages/pose.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navi/pages/pose_detector_view.dart';


class Fitness extends StatefulWidget {

  @override
  State<Fitness> createState() => _FitnessState();
}


class _FitnessState extends State<Fitness> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yoga.',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      // OutlinedButton.icon(
                      //     onPressed: () {},
                      //     icon: Icon(Icons.settings),
                      //     label: Text('Settings')
                      // ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Workouts',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 16),
                  StreamBuilder<List<Pose>>(
                    stream: readUserPoses(),
                    builder: (context, snapshot){
                      print(snapshot.hasData);
                      if(snapshot.hasData){
                        final poses = snapshot.data!;
                        print("Working");
                        return ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: poses.map(buildPose).toList(),
                        );
                      }else{
                        print("Not Working");
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
                  SizedBox(height: 104)
                ]
              ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => NewPose()),
          // );
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                )
              ),
              isScrollControlled: true,
              isDismissible: true,
              builder: (BuildContext context) {
                return DraggableScrollableSheet(
                    initialChildSize: 0.75, //set this as you want
                    maxChildSize: 0.75, //set this as you want
                    minChildSize: 0.75, //set this as you want
                    expand: true,
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              StreamBuilder<List<Pose>>(
                                  stream: readNewPoses(),
                                  builder: (context, snapshot){
                                    print(snapshot.hasData);
                                    if(snapshot.hasData){
                                      final poses = snapshot.data!;
                                      print("Working");
                                      return ListView(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: poses.map(addPose).toList(),
                                      );
                                    }else{
                                      print("Not Working");
                                      return Center(child: CircularProgressIndicator());
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ); //whatever you're returning, does not have to be a Container
                    }
                );
              }
          );
        },
        icon: Icon(Icons.add),
        label: Text('New Pose'),
        // backgroundColor: Colors.pink[500],
      ),
    );
  }

  Stream<List<Pose>> readUserPoses() => FirebaseFirestore.instance
      .collection('userPoses')
      // .orderBy('name', descending: false)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Pose.fromJson(doc.data())).toList());

  Stream<List<Pose>> readNewPoses() => FirebaseFirestore.instance
      .collection('poses')
      .orderBy('name', descending: false)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Pose.fromJson(doc.data())).toList());

}


Widget buildPose(Pose pose){

  Future deleteUserPose() async {
    FirebaseFirestore.instance.collection("userPoses").doc(pose.id).delete().then(
    (doc) => print(pose.name + "Document deleted"),
    onError: (e) => print("Error updating document $e"),
  );
  }
  return Builder(
    builder: (context) => Dismissible(
      key: Key(pose.id),
      onDismissed: (direction) {
        // Then show a snackbar.
        deleteUserPose();
        ScaffoldMessenger.of(context)
            .showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                  content: Text(
                      pose.name + ' removed',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),)
                )
            );
      },
      background: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              splashColor: Theme.of(context).colorScheme.tertiary,
              onTap: () {
                print(pose.name);
                print(pose.reps);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PoseDetectorView(poseName: pose.name,)),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: SizedBox(
                  height: 104,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              pose.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit,
                              size: 14,
                            ),
                            label: Text(
                              '${pose.reps}' + ' reps',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
                      ),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: SizedBox(
                          width: 96,
                          child: Center(
                            child: SvgPicture.asset('assets/' + pose.name + '.svg'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget addPose(Pose pose){
  Future createNewPose({required String name, required String reps}) async {
    // Reference to document
    final docPose = FirebaseFirestore.instance.collection('userPoses').doc();

    final json = {
      'id': docPose.id,
      'name': name,
      'reps': reps,

    };
    // Create document and write data to Firebase
    await docPose.set(json);
  }

  return Builder(
    builder: (context) => Row(
      children: [
        Expanded(
          flex: 1,
          child: InkWell(
            splashColor: Theme.of(context).colorScheme.tertiary,
            onTap: () {
              print(pose.name);
              print(pose.reps);
              createNewPose( name: pose.name, reps: pose.reps);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SizedBox(
                height: 104,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            pose.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.edit,
                            size: 14,
                          ),
                          label: Text(
                            '${pose.reps}' + ' reps',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: SizedBox(
                        width: 96,
                        child: Center(
                          child: SvgPicture.asset('assets/' + pose.name + '.svg'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

