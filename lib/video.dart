import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ParticipantWidget extends StatefulWidget {
  final Participant participant;
  const ParticipantWidget(this.participant, {Key? key}) : super(key: key);

  @override
  _ParticipantWidgetState createState() => _ParticipantWidgetState();
}

class _ParticipantWidgetState extends State<ParticipantWidget> {
  TrackPublication? videoTrackPub;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onTrackChange);
    _setVideoTrack();
  }

  void _onTrackChange() {
    setState(() {
      _setVideoTrack();
    });
  }

  void _setVideoTrack() {
    var videoTracks = <TrackPublication>[];
    if (widget.participant is RemoteParticipant) {
      videoTracks = (widget.participant as RemoteParticipant).videoTrackPublications.where((pub) {
        return pub.track is VideoTrack && pub.subscribed && !pub.muted;
      }).toList();
    } else if (widget.participant is LocalParticipant) {
      videoTracks = (widget.participant as LocalParticipant).videoTrackPublications.where((pub) {
        return pub.track is VideoTrack && pub.subscribed && !pub.muted;
      }).toList();
    }

    if (videoTracks.isNotEmpty) {
      videoTrackPub = videoTracks.first;
    } else {
      videoTrackPub = null;
    }
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onTrackChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: videoTrackPub != null && videoTrackPub!.track is VideoTrack
          ? VideoTrackRenderer(videoTrackPub!.track as VideoTrack)
          : Container(
        color: Colors.grey,
        child: const Center(
          child: Text('No Video'),
        ),
      ),
    );
  }
}