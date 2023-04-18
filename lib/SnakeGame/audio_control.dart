// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
//
// class AudioControl extends StatelessWidget {
//   final AudioPlayer audioPlayer;
//   const AudioControl({Key? key, required this.audioPlayer}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<PlayerState>(
//       stream: audioPlayer.playerStateStream,
//       builder: (context,snapshot){
//         final playerState = snapshot.data;
//         final processingState = playerState?.processingState;
//         final playing = playerState?.playing;
//         //not playing
//         if(!(playing??false)){
//           return audioPlayer.play;
//         }
//
//       }
//     );
//   }
// }
