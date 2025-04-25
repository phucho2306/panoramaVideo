import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  final File videoFile;

  LoadingCubit({required this.videoFile}) : super(LoadingInitial()) {
    _uploadVideo();
  }

  Future<void> _uploadVideo() async {
    emit(LoadingInProgress());
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://160.191.164.16:8234/image_stitching'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        emit(LoadingSuccess(base64Image: jsonResponse['data']));
      } else {
        emit(const LoadingError(message: 'Video upload failed.'));
      }
    } catch (e) {
      emit(LoadingError(message: 'Error while uploading: $e'));
    }
  }
}