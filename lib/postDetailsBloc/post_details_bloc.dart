import 'dart:async';
import 'package:jobs/blocs/commonBloc/postDetailsBloc/post_details_event.dart';
import 'package:jobs/blocs/commonBloc/postDetailsBloc/post_details_state.dart';
import 'package:jobs/data/models/employer_model.dart';
import 'package:jobs/data/models/job_post_model.dart';
import 'package:jobs/data/repositories/employers_repository.dart';
import 'package:jobs/data/repositories/jobs_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:jobs/data/repositories/workers_repository.dart';

class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  JobsRepository _jobsRepository = JobsRepository();
  WorkersRepository _workersRepository = WorkersRepository();
  EmployersRepository _employersRepository = EmployersRepository();
  StreamSubscription _applicationsSubscription;

  @override
  PostDetailsState get initialState => PostLoading();

  @override
  Stream<PostDetailsState> mapEventToState(PostDetailsEvent event) async* {
    if (event is FetchPostDetails) {
      yield* _mapfetchPostDetailsToState(event);
    } else if (event is CheckIfApplied) {
      yield* _mapCheckIfAppliedToState(event);
    } else if (event is ApplyOnJob) {
      yield* _mapApplyOnJobToState(event);
    } else if (event is FetchAllApplications) {
      yield* _mapFetchAllApplicationsToState(event);
    } else if (event is UpdatedApplications) {
      yield* _mapUpdatedApplicationsToState(event);
    } else if (event is TranslateJobPost) {
      yield* _mapTranslateJobPostToState(event);
    } else if (event is CheckIfGuest) {
      yield* _mapCheckIfGuestToState(event);
    }
  }

  // 1.
  Stream<PostDetailsState> _mapfetchPostDetailsToState(
      FetchPostDetails event) async* {
    yield PostLoading();
    try {
      JobPostModel jobPostModel =
          _jobsRepository.getJobPostFromSnapShot(event.documentSnapshot);
      EmployerModel employerModel =
          await _employersRepository.getEmployerAsFuture();
      yield PostLoaded(
        jobPostModel: jobPostModel,
        employerModel: employerModel,
      );
    } catch (e) {
      yield PostLoadFailure(message: e.toString());
    }
  }

  // 2.
  Stream<PostDetailsState> _mapCheckIfAppliedToState(
      CheckIfApplied event) async* {
    try {
      bool hasApplied =
          await _jobsRepository.hasAppliedOnAJob(event.documentReference);
      if (hasApplied) {
        yield AlreadyApplied();
      } else {
        yield NotApplied(documentReference: event.documentReference);
      }
    } catch (e) {
      yield ApplicationCheckFailed(message: e.toString());
    }
  }

  // 3.
  Stream<PostDetailsState> _mapApplyOnJobToState(ApplyOnJob event) async* {
    yield Applying();
    try {
      _jobsRepository.applyOnASingleJob(event.documentReference);
      yield SuccessfullyApplied();
    } catch (e) {
      yield FailedToApply(message: e.toString());
    }
  }

  // 4. number of applications on a post
  Stream<PostDetailsState> _mapFetchAllApplicationsToState(
      FetchAllApplications event) async* {
    yield ApplicationsLoading();
    try {
      _applicationsSubscription?.cancel();
      _applicationsSubscription = _jobsRepository
          .getNumberOfApplicationsInAJob(event.documentReference)
          .listen((noOfApplications) {
        add(
          UpdatedApplications(
            applications: noOfApplications,
            documentReference: event.documentReference,
          ),
        );
      });
    } catch (e) {
      yield ApplicationsLoadFailure(message: e.toString());
    }
  }

  // 5.
  Stream<PostDetailsState> _mapUpdatedApplicationsToState(
      UpdatedApplications event) async* {
    if (event.applications == 0) {
      yield NoApplication();
    } else {
      yield ApplicationsLoaded(
        totalApplications: event.applications,
        documentReference: event.documentReference,
      );
    }
  }

  // 6.
  Stream<PostDetailsState> _mapTranslateJobPostToState(
      TranslateJobPost event) async* {
    yield Translating();
    try {
      JobPostModel jobPostModel = await _jobsRepository.translateJobPost(
          event.languageCode, event.jobPostModel);
      yield TranslationSuccessful(jobPostModel: jobPostModel);
    } catch (e) {
      yield TranslationFailure(message: e.toString());
    }
  }

  // 7.
  Stream<PostDetailsState> _mapCheckIfGuestToState(CheckIfGuest event) async* {
    bool isGuest = await _workersRepository.isGuest();
    if (isGuest) {
      yield GuestState();
    } else {
      add(CheckIfApplied(documentReference: event.documentReference));
      // yield NotGuestState();
    }
  }

  @override
  Future<void> close() {
    _applicationsSubscription?.cancel();
    return super.close();
  }
}
