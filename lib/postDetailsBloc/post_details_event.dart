import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:jobs/data/models/job_post_model.dart';
import 'package:meta/meta.dart';

abstract class PostDetailsEvent extends Equatable {}

// 1.
// done
class FetchPostDetails extends PostDetailsEvent {
  final DocumentSnapshot documentSnapshot;

  FetchPostDetails({@required this.documentSnapshot});

  @override
  List<Object> get props => [documentSnapshot];
}

// 2. for worker
class CheckIfApplied extends PostDetailsEvent {
  final DocumentReference documentReference;

  CheckIfApplied({@required this.documentReference});

  @override
  List<Object> get props => [documentReference];
}

// 3. for worker
class ApplyOnJob extends PostDetailsEvent {
  final DocumentReference documentReference;

  ApplyOnJob({@required this.documentReference});

  @override
  List<Object> get props => [documentReference];
}

// 4. for employer
class FetchAllApplications extends PostDetailsEvent {
  final DocumentReference documentReference;

  FetchAllApplications({@required this.documentReference});

  @override
  List<Object> get props => [documentReference];
}

// 5. for employer
class UpdatedApplications extends PostDetailsEvent {
  final int applications;
  final DocumentReference documentReference;

  UpdatedApplications({@required this.applications, @required this.documentReference});

  @override
  List<Object> get props => [applications, documentReference];
}

// 6.
class TranslateJobPost extends PostDetailsEvent {
  final String languageCode;
  final JobPostModel jobPostModel;

  TranslateJobPost({@required this.languageCode, @required this.jobPostModel});

  @override
  List<Object> get props => [languageCode, jobPostModel];
}

// 7.
class CheckIfGuest extends PostDetailsEvent {
  final DocumentReference documentReference;

  CheckIfGuest({@required this.documentReference});
  @override
  List<Object> get props => [documentReference];
}
