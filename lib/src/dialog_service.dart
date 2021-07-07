part of dialog_service;

enum DialogType { error, info, announcment }

class DialogService {
  Future<void> showErrorModalWithText(
    BuildContext context, {
    required String contentText,
    String? actionText,
    bool scrollable = false,
    DialogType dialogType = DialogType.info,
  }) async {
    final widget = DialogWidgets().textBottomUpDialog(
      context,
      contentText: contentText,
      okText: actionText,
      scrollable: scrollable,
      dialogType: dialogType,
    );

    await this._presentModal(context, widget);
  }

  Future<bool?> showModalReturnBool(
    BuildContext context, {
    required String contentText,
    String? okText,
    String? nonText,
    bool scrollable = false,
    TextAlign contentAlign = TextAlign.start,
    DialogType dialogType = DialogType.info,
  }) async {
    final widget = DialogWidgets().boolBottomUpDialog(
      context,
      contentText: contentText,
      okText: okText,
      nonText: nonText,
      scrollable: scrollable,
      contentAlign: contentAlign,
      dialogType: dialogType,
    );

    return await this._presentModal<bool>(context, widget);
  }

  void showAnimatedPullBottomSheet(
    BuildContext context, {
    required Widget child,
    bool showTitle = false,
    String? titleText,
  }) {
    Widget _builder(BuildContext context) {
      return PullSheetPickerWidget(
        context: context,
        title: titleText,
        showTitle: showTitle,
        child: child,
        onEmptySpaceTabbed: () {
          OverlayServices.dismissOverlay();
        },
      );
    }

    OverlayServices.insertOverlay(context, _builder);
  }

  void dismissOverlay() {
    OverlayServices.dismissOverlay();
  }

  Future<T?> showModalReturnData<T>(BuildContext context, Widget widget) async {
    final result = await this._presentModal<T>(context, widget);
    return result;
  }

  Future<T?> _presentModal<T>(BuildContext context, Widget childWidget) async {
    bool _fromTop = false;

    return await showGeneralDialog(
      barrierLabel: "kapat_text", //TODO: LOCALIZE HERE
      useRootNavigator: false,
      barrierDismissible: true,
      barrierColor: Theme.of(context).dialogTheme.backgroundColor ??
          Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return childWidget;
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: new CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween(
                    begin: Offset(0, _fromTop ? -0.1 : 0.1), end: Offset(0, 0))
                .animate(anim1),
            child: child,
          ),
        );
      },
    );
  }
}
