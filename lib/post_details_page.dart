import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jobs/blocs/commonBloc/postDetailsBloc/post_details_bloc.dart';
import 'package:jobs/blocs/commonBloc/postDetailsBloc/post_details_event.dart';
import 'package:jobs/blocs/commonBloc/postDetailsBloc/post_details_state.dart';
import 'package:jobs/data/models/employer_model.dart';
import 'package:jobs/data/models/job_post_model.dart';
import 'package:jobs/res/app_assets.dart';
import 'package:jobs/res/app_strings.dart';
import 'package:jobs/ui/pages/employer/applicants_list_page.dart';
import 'package:jobs/ui/widgets/errors/center_error.dart';
import 'package:jobs/ui/widgets/loadings/job_post_loading_ui.dart';
import 'package:jobs/utils/connectivity_service.dart';
import 'package:jobs/utils/helper.dart';
import 'package:meta/meta.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sample/postDetailsBloc/post_details_bloc.dart';
import 'package:sample/postDetailsBloc/post_details_state.dart';
import 'package:share/share.dart';

/**
 * const checked
 * EmpoyerProfilePageBloc is needed for getting updated company name
 */

class PostDetailsPageParent extends StatelessWidget {
  final bool isWorker;
  final JobPostModel jobPostModel;
  final DocumentReference documentReference;
  final DocumentSnapshot documentSnapshot;

  const PostDetailsPageParent({
    Key key,
    @required this.isWorker,
    @required this.jobPostModel,
    this.documentReference,
    @required this.documentSnapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailsBloc>(
      create: (context) => PostDetailsBloc(),
      child: PostDetailsPage(
        isWorker: isWorker,
        documentSnapshot: documentSnapshot,
        jobPostModel: jobPostModel,
        documentReference: documentReference,
      ),
    );
  }
}

class PostDetailsPage extends StatefulWidget {
  final bool isWorker;
  final JobPostModel jobPostModel;
  final DocumentReference documentReference;
  final DocumentSnapshot documentSnapshot;

  const PostDetailsPage({
    Key key,
    @required this.isWorker,
    @required this.jobPostModel,
    this.documentReference,
    @required this.documentSnapshot,
  }) : super(key: key);
  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final String _TAG = "_PostDetailsPageState";

  PostDetailsBloc _postDetailsBloc;

  @override
  void initState() {
    super.initState();
    _postDetailsBloc = BlocProvider.of<PostDetailsBloc>(context);
    // event for the 1st child
    _postDetailsBloc.add(FetchPostDetails(
      documentSnapshot: widget.documentSnapshot,
    ));
    // event for the 2nd child
    if (widget.isWorker) {
      _postDetailsBloc.add(
        CheckIfGuest(
          documentReference: widget.documentReference,
        ),
      );
    } else {
      _postDetailsBloc.add(
        FetchAllApplications(
          documentReference: widget.documentReference,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(widget.jobPostModel.title),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.grey),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              String textToShare =
                  "JOBBEE\n ${widget.jobPostModel.title} - ${widget.jobPostModel.jobDescription}\n Company - ${widget.jobPostModel.companyName}";

              String finalText =
                  "$textToShare\n Download app from Google Play Store : ${AppStrings.goolePlayAppLink}";
              Share.share(finalText);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // for fetching post details
          BlocBuilder<PostDetailsBloc, PostDetailsState>(
            builder: (context, state) {
              if (state is PostLoading) {
                Helper.logPrint(_TAG, "${state.toString()} ------------ ");
                return JobPostLoadingUi();
              }
              if (state is PostLoaded) {
                Helper.logPrint(_TAG, "${state.toString()} ------------ ");
                return _PostLoadedUi(
                  jobPostModel: state.jobPostModel,
                  employerModel: state.employerModel,
                );
              }
              if (state is PostLoadFailure) {
                Helper.logPrint(_TAG, "${state.toString()} ------------ ");
                return CenterError(message: state.message);
              }
              Helper.logPrint(_TAG, "${state.toString()} ----else---- ");
              return _EmptyUi();
            },
          ),
          BlocBuilder<PostDetailsBloc, PostDetailsState>(
            builder: (context, state) {
              if (state is GuestState) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _GuestUi();
              }
              if (state is AlreadyApplied) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _AlreadyAppliedUi();
              }
              if (state is NotApplied) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _ApplyButtonUi(
                  documentReference: state.documentReference,
                );
              }
              if (state is ApplicationCheckFailed) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _ErrorUi(message: state.message);
              }
              if (state is ApplicationsLoading) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _LoadingUi();
              }
              if (state is ApplicationsLoaded) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _ApplicationsUi(
                  applications: state.totalApplications,
                  documentReference: state.documentReference,
                );
              }
              if (state is NoApplication) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _NoApplicationUi();
              }
              if (state is ApplicationsLoadFailure) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _ErrorUi(message: state.message);
              }
              if (state is Applying) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _LoadingUi();
              }
              if (state is SuccessfullyApplied) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _SuccessfullyAppliedUi();
              }
              if (state is FailedToApply) {
                Helper.logPrint(_TAG, "${state.toString()} ");
                return _ErrorUi(message: state.message);
              }
              Helper.logPrint(_TAG, "${state.toString()} ELSE ");
              return _EmptyUi();
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyUi extends StatelessWidget {
  const _EmptyUi();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 0.0);
  }
}

class _PostLoadedUi extends StatelessWidget {
  ProgressDialog progressDialog;
  var currentSelected;
  var scrHeight, scrWidth;

  var leftItemsFlex = 2;
  var rightItemsFlex = 3;
  final double buttonRadius = 50.0;
  static const double _logoSize = 70.0;

  final JobPostModel jobPostModel;
  final EmployerModel employerModel;

  _PostLoadedUi(
      {Key key, @required this.jobPostModel, @required this.employerModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);
    scrWidth = MediaQuery.of(context).size.width - 40.0;
    scrHeight = MediaQuery.of(context).size.height;
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: <Widget>[
        //1. date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Posted on  ${Helper.formatDateTime(jobPostModel.date)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            // languagesDropDown(),
          ],
        ),
        //2. post image
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 30.0, bottom: 10.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Helper.isNullOrEmpty(jobPostModel.jobImageUrl) != true
                  ? Image.network(
                      jobPostModel.jobImageUrl,
                      width: scrWidth,
                      height: 200.0,
                      fit: BoxFit.cover,
                    )
                  : const SizedBox(height: 0.0)),
        ),
        //3. title
        Container(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: Text(
            jobPostModel.title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        //4. position
        Container(
          padding: const EdgeInsets.only(top: 10.0, left: 20.0, bottom: 25.0),
          child: Text(
            jobPostModel.jobPosition,
            style: const TextStyle(fontSize: 17.0),
          ),
        ),
        //5. company name and logo
        Container(
          padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 20.0),
                child: ClipOval(
                  child: employerModel.logoUrl == null
                      ? Image.asset(
                          AppAssets.workerPlaceHolderImage,
                          height: _logoSize,
                          width: _logoSize,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          employerModel.logoUrl,
                          width: _logoSize,
                          height: _logoSize,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                width: scrWidth * 0.6,
                child: Text(
                  employerModel.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 19.0,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
        //6. description
        Container(
          width: scrWidth * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            jobPostModel.jobDescription,
            overflow: TextOverflow.ellipsis,
            maxLines: 6,
            style: const TextStyle(
              fontSize: 15.0,
              height: 1.5,
            ),
          ),
        ),
        // Experience
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Experience  ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                width: scrWidth * 0.55,
                child: Text(
                  jobPostModel.experience,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // vacancies
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Vacancies ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                width: scrWidth * 0.5,
                child: Text(
                  jobPostModel.vacancies.toString(),
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // language
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Job Language ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                width: scrWidth * 0.5,
                child: Text(
                  jobPostModel.language != null ? jobPostModel.language : "N/A",
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // job type
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Job Type ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                width: scrWidth * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  jobPostModel.jobType,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // preferred gender
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Preferred Gender ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                width: scrWidth * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  jobPostModel.preferredGender != null
                      ? jobPostModel.preferredGender
                      : "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // job category
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Job Category ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                width: scrWidth * 0.5,
                child: Text(
                  jobPostModel.jobCategory,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // salary range
        Container(
          width: scrWidth,
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Salary Range ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                width: scrWidth * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  jobPostModel.salaryRange + " " + jobPostModel.salaryType,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 6,
                ),
              ),
            ],
          ),
        ),
        // schedule
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Schedule ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                width: scrWidth * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  jobPostModel.schedule,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // location
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Location ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                width: scrWidth * 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Wrap(
                  children: <Widget>[
                    Text(
                      "${jobPostModel.name}, ${jobPostModel.subLocality}, ${jobPostModel.country}",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // deadline
        Container(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: scrWidth * 0.4,
                child: const Text(
                  "Deadline ",
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                width: scrWidth * 0.5,
                child: Text(
                  // TODO deadline
                  Helper.formatDateTime(jobPostModel.deadline),
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Address
        const Padding(
          padding: EdgeInsets.only(left: 20.0, bottom: 10.0, top: 20.0),
          child: const Text(
            "Address :",
            style: const TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ),
        Container(
            width: scrWidth * 0.7,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              Helper.isNullOrEmpty(jobPostModel.address)
                  ? "N/A"
                  : jobPostModel.address,
              style: const TextStyle(
                fontSize: 16.0,
                // color: Colors.black,
              ),
            )),
        const SizedBox(
          height: 200.0,
        )
      ],
    );
  }
}

class _AlreadyAppliedUi extends StatelessWidget {
  final double buttonRadius = 50.0;
  double _scrWidth;

  @override
  Widget build(BuildContext context) {
    _scrWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 0.0,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        width: _scrWidth,
        height: 60.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: Colors.blue,
        ),
        child: const Text(
          "You've already applied on this job",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}

class _ErrorUi extends StatelessWidget {
  final String message;

  const _ErrorUi({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double buttonRadius = 50.0;
    double _scrWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 0.0,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        width: _scrWidth,
        height: 60.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: Colors.blue,
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}

class _NoApplicationUi extends StatelessWidget {
  final double buttonRadius = 50.0;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width,
        height: 40.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(buttonRadius)),
        child: const Text(
          "No Application Yet",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17.0,
          ),
        ),
      ),
    );
  }
}

class _GuestUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width,
        height: 60.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: Colors.blue,
        ),
        child: const Text(
          "You've already applied on this job",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}

class _ApplyButtonUi extends StatelessWidget {
  final DocumentReference documentReference;
  ProgressDialog progressDialog;
  _ApplyButtonUi({Key key, @required this.documentReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context);
    return Positioned(
      bottom: 0.0,
      child: InkWell(
        onTap: () async {
          bool isConnected = await ConnectivityService().hasConnection();
          if (isConnected) {
            BlocProvider.of<PostDetailsBloc>(context).add(
              ApplyOnJob(
                documentReference: documentReference,
              ),
            );
          } else {
            Fluttertoast.showToast(msg: "Check Internet Connection");
          }
        },
        child: Container(
          margin: const EdgeInsets.all(20.0),
          width: MediaQuery.of(context).size.width,
          height: 60.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            color: Colors.red,
          ),
          child: const Text(
            "Apply Now",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double buttonRadius = 50.0;
    double _scrWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 0.0,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        width: _scrWidth,
        height: 60.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: Colors.blue,
        ),
        child: SpinKitThreeBounce(color: Colors.green),
      ),
    );
  }
}

class _ApplicationsUi extends StatelessWidget {
  final int applications;
  final DocumentReference documentReference;

  const _ApplicationsUi({
    Key key,
    @required this.applications,
    @required this.documentReference,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      child: InkWell(
        onTap: () {
          Get.to(ApplicantsListPageParent(
            documentReference: documentReference,
          ));
        },
        child: Container(
          margin: const EdgeInsets.all(20.0),
          width: MediaQuery.of(context).size.width,
          height: 60.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Text(
            "$applications Applications",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessfullyAppliedUi extends StatelessWidget {
  const _SuccessfullyAppliedUi();

  @override
  Widget build(BuildContext context) {
    final double buttonRadius = 50.0;
    double _scrWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 0.0,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        width: _scrWidth,
        height: 60.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonRadius),
          color: Colors.blue,
        ),
        child: Text(
          "Appliced Successfully!",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}