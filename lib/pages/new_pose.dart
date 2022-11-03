import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:navi/pages/pose.dart';
import 'package:flutter_svg/flutter_svg.dart';



class NewPose extends StatefulWidget {

  @override
  State<NewPose> createState() => _NewPoseState();
}


class _NewPoseState extends State<NewPose> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Pose'),
      ),
      body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    StreamBuilder<List<Pose>>(
                        stream: readPoses(),
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
                  ],
                ),
              ),
            ),
      ),

    );
  }

  Stream<List<Pose>> readPoses() => FirebaseFirestore.instance
      .collection('poses')
      .orderBy('name', descending: false)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Pose.fromJson(doc.data())).toList());

}

Widget buildPose(Pose pose){
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
                splashColor: Colors.white,
                onTap: () {
                  print(pose.name);
                  print(pose.reps);
                  createNewPose( name: pose.name, reps: pose.reps);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondaryContainer,
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
                          color: Theme.of(context).colorScheme.surface,
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

