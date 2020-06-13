import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:jobs/data/models/employer_model.dart';
import 'package:jobs/data/models/job_post_model.dart';
import 'package:jobs/ui/pages/common/post_details_page.dart';
import 'package:meta/meta.dart';

abstract class PostDetailsState extends Equatable {}

// 1.
// done
class PostLoading extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 2.
// done
class PostLoaded extends PostDetailsState {
  final JobPostModel jobPostModel;
  // to get updated company name
  final EmployerModel employerModel;

  PostLoaded({@required this.jobPostModel, @required this.employerModel});

  @override
  List<Object> get props => [jobPostModel, employerModel];
}

// 3.
// done
class PostLoadFailure extends PostDetailsState {
  final String message;

  PostLoadFailure({@required this.message});

  @override
  List<Object> get props => [message];
}

// 4. for worker
// done
class AlreadyApplied extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 5. for worker
// done
class NotApplied extends PostDetailsState {
  final DocumentReference documentReference;

  NotApplied({@required this.documentReference});
  @override
  List<Object> get props => [];
}

// 6. for worker
// done
class ApplicationCheckFailed extends PostDetailsState {
  final String message;

  ApplicationCheckFailed({@required this.message});
  @override
  List<Object> get props => [message];
}

// 7. for worker
// done
class Applying extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 8. for worker
// done
class SuccessfullyApplied extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 9. for worker
// done
class FailedToApply extends PostDetailsState {
  final String message;

  FailedToApply({@required this.message});
  @override
  List<Object> get props => [message];
}

// 10. for employer
// done
class ApplicationsLoading extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 11. for employer
// done
class ApplicationsLoaded extends PostDetailsState {
  final int totalApplications;
  final DocumentReference documentReference;

  ApplicationsLoaded({
    @required this.totalApplications,
    @required this.documentReference,
  });

  @override
  List<Object> get props => [totalApplications, documentReference];
}

// 12.
class NoApplication extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 13. for employer
// done
class ApplicationsLoadFailure extends PostDetailsState {
  final String message;

  ApplicationsLoadFailure({@required this.message});

  @override
  List<Object> get props => [message];
}

// 14.
class Translating extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 15.
class TranslationSuccessful extends PostDetailsState {
  final JobPostModel jobPostModel;

  TranslationSuccessful({@required this.jobPostModel});
  @override
  List<Object> get props => [jobPostModel];
}

// 16.
class TranslationFailure extends PostDetailsState {
  final String message;

  TranslationFailure({@required this.message});
  @override
  List<Object> get props => [message];
}

// 17.
// done
class GuestState extends PostDetailsState {
  @override
  List<Object> get props => [];
}

// 17.
// class NotGuestState extends PostDetailsState {
//   @override
//   List<Object> get props => [];
// }
