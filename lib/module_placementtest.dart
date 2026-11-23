import "package:cloud_firestore/cloud_firestore.dart";

final FirebaseFirestore _db = FirebaseFirestore.instance;

//Logika pembaruan level user
String _promoteLevel(String level){
  const levels = ['A1','A2','B1','B2'];
  int index = levels.indexOf(level);
  return index < levels.length - 1 ? levels[index + 1]: level; //conditional logic: condition ? expressionIfTrue : expressionIfFalse
}

String _demoteLevel(String level){
  const levels = ['A1','A2','B1','B2'];
  int index = levels.indexOf(level);
  return index > 0? levels[index-1]:level;
}

Future<void> handleAnswer(bool isCorrect, String userId) async{
  final DocumentReference stateRef = _db
  .collection('users')
  .doc(userId)
  .collection('placement_state')
  .doc('current_test');

  await _db.runTransaction((transaction) async{
    final snapshot = await transaction.get(stateRef);

    if (!snapshot.exists){
      //initialisasi test state
      transaction.set(stateRef, {
        'current_level': 'A1',
        'correct': 0,
        'incorrect': 0,
      });
      return;
    }

    String level = snapshot.get('current_level') ?? 'A1'; //Defaultnya A1 jika null
    int correct = snapshot.get('correct') ?? 0 ;
    int incorrect = snapshot.get('incorrect') ?? 0;

    if(isCorrect){
      correct++;
    } else {
      incorrect++;
    }

    transaction.update(stateRef, {
      'current_level': level,
      'correct': correct,
      'incorrect': incorrect,
    });
  });
}

Future<void> ubahLevel(String userId) async{
  
}

//Fetch Pertanyaan
Future<Map<String, dynamic>?> fetchQuestion(String currentLevel) async {
  final querySnapshot = await _db
  .collection('questions')
  .where('level', isEqualTo: currentLevel)
  .limit(1)
  .get();

  if (querySnapshot.docs.isNotEmpty){
    return querySnapshot.docs.first.data();
  }
  return null;
}