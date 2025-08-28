import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ioclcustomerconnect/utils/validators.dart';
import 'package:ioclcustomerconnect/views/themes/custom_theme.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class FeedbackPopupView extends StatefulWidget {
  const FeedbackPopupView({
    Key key,
    this.onApplyClick,
    this.onCancelClick,
    this.barrierDismissible = true,
    this.type,
  }) : super(key: key);

  final bool barrierDismissible;
  final Function onApplyClick;

  final Function onCancelClick;
  final String type;
  @override
  _FeedbackPopupViewState createState() => _FeedbackPopupViewState();
}

class _FeedbackPopupViewState extends State<FeedbackPopupView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  final _remarkFieldController = TextEditingController();
  double rating = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: animationController.value,
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  if (widget.barrierDismissible) {
                    Navigator.pop(context);
                  }
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomTheme.buildLightTheme().backgroundColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              offset: const Offset(4, 4),
                              blurRadius: 8.0),
                        ],
                      ),
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        widget.type == 'UP'
                                            ? 'Give Rating'
                                            : 'Your Remarks',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 1,
                            ),
                            Container(
                              child: const SizedBox(
                                height: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16, top: 8),
                              child: Center(
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    children: <Widget>[
                                      widget.type == 'UP'
                                          ? SmoothStarRating(
                                              allowHalfRating: false,
                                              onRated: (v) {
                                                this.rating = v;
                                                setState(() {});
                                              },
                                              starCount: 5,
                                              rating: rating,
                                              size: 30,
                                              color:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor,
                                              borderColor:
                                                  CustomTheme.buildLightTheme()
                                                      .primaryColor,
                                            )
                                          : TextFormField(
                                              controller:
                                                  _remarkFieldController,
                                              // inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),],
                                              decoration: InputDecoration(
                                                  counterText: "",
                                                  hintText: 'Remarks',
                                                  hintStyle: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic)),
                                              keyboardType:
                                                  TextInputType.multiline,
                                              minLines: 1,
                                              maxLength: 200,
                                              maxLines: 5,
                                              validator: (value) => value
                                                          .isEmpty ||
                                                      Validators.removeEmoji
                                                              .removemoji(
                                                                  value) ==
                                                          ""
                                                  ? 'Non Empty Text Field.'
                                                  : null,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                      widget.type == 'UP'
                                          ? FormField<void>(
                                              builder: (state) {
                                                return Container();
                                              },
                                              validator: (value) => rating == 0
                                                  ? 'Please Rate'
                                                  : null,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: const SizedBox(
                                height: 10,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16, top: 8),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: CustomTheme.buildLightTheme()
                                      .primaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(24.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.6),
                                      blurRadius: 8,
                                      offset: const Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(24.0)),
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      if (_isFormValidated()) {
                                        widget.onApplyClick(rating.round(),
                                            _remarkFieldController.text);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        'Submit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isFormValidated() {
    final FormState form = formKey.currentState;
    return form.validate();
  }
}
