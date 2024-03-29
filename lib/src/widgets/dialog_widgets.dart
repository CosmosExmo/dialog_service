import 'package:dialog_service/dialog_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogWidgets {
  Widget alertDialog(
    BuildContext context, {
    String contentText = "",
    String actionText = "",
    bool scrollable = false,
    TextStyle? contentStyle,
    double borderRadius = 12,
  }) {
    return AlertDialog(
      scrollable: scrollable,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      content: SelectableText(
        contentText,
        style: contentStyle ?? Theme.of(context).dialogTheme.contentTextStyle,
      ),
      actions: [
        ElevatedButton(
          child: Text(actionText),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  Widget textBottomUpDialog(
    BuildContext context, {
    required String contentText,
    required String okText,
    bool? scrollable,
    TextStyle? contentStyle,
    double borderRadius = 12,
    TextAlign? contentAlign,
    DialogType? dialogType,
  }) {
    return _BottomUpDialogWidget(
      dialogType: dialogType,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: SelectableText(
              contentText,
              style: contentStyle ??
                  Theme.of(context).dialogTheme.contentTextStyle,
              textAlign: contentAlign,
            ),
          ),
          _MenuButtonWidget(
            text: okText,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget boolBottomUpDialog(
    BuildContext context, {
    String contentText = "",
    String? okText = "Tamam",
    String? nonText = "İptal",
    bool? scrollable,
    TextStyle? contentStyle,
    double borderRadius = 12,
    TextAlign? contentAlign,
    DialogType? dialogType,
  }) {
    return _BottomUpDialogWidget(
      dialogType: dialogType,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: SelectableText(
              contentText,
              style: contentStyle ??
                  Theme.of(context).dialogTheme.contentTextStyle,
              textAlign: contentAlign,
            ),
          ),
          _MenuButtonWidget(
            text: okText,
            onPressed: () => Navigator.pop(context, true),
          ),
          if (kIsWeb) const SizedBox(height: 20),
          _MenuButtonWidget(
            text: nonText,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }

  Widget inputDialog(
    BuildContext context, {
    required String titleText,
    required String okText,
    required String nonText,
    TextStyle? titleStyle,
    double borderRadius = 12,
    TextAlign? titleAlign,
    DialogType dialogType = DialogType.none,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    InputDecoration? inputDecoration,
    Color? buttonColor,
    TextStyle? buttonTextStyle,
    double? buttonHeight,
  }) {
    final _controller = TextEditingController();
    return _BottomUpDialogWidget(
      dialogType: dialogType,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SelectableText(
            titleText,
            style: titleStyle ?? Theme.of(context).dialogTheme.contentTextStyle,
            textAlign: titleAlign,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).highlightColor,
                    blurRadius: 0.5,
                    spreadRadius: 0.5,
                    offset: const Offset(0.0, 0.0),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: inputDecoration,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                ),
              ),
            ),
          ),
          _MenuButtonWidget(
            text: okText,
            onPressed: () => Navigator.pop(context, _controller.text),
            buttonColor: buttonColor,
            buttonTextStyle: buttonTextStyle,
            buttonHeight: buttonHeight,
          ),
          if (kIsWeb) const SizedBox(height: 20),
          _MenuButtonWidget(
            text: nonText,
            onPressed: () => Navigator.pop(context),
            buttonColor: buttonColor,
            buttonTextStyle: buttonTextStyle,
            buttonHeight: buttonHeight,
          ),
        ],
      ),
    );
  }
}

class _MenuButtonWidget extends StatelessWidget {
  final Function onPressed;
  final String? text;
  final Color? buttonColor;
  final TextStyle? buttonTextStyle;
  final double? buttonHeight;
  const _MenuButtonWidget({
    Key? key,
    required this.onPressed,
    required this.text,
    this.buttonColor,
    this.buttonTextStyle,
    this.buttonHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ElevatedButton(
          onPressed: onPressed as void Function()?,
          child: Text(
            text!,
            textAlign: TextAlign.center,
            style: buttonTextStyle,
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(buttonHeight ?? 35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: buttonColor,
          ),
        ),
      ),
    );
  }
}

class _BottomUpDialogWidget extends StatelessWidget {
  final Widget child;
  final DialogType? dialogType;
  const _BottomUpDialogWidget(
      {Key? key, required this.child, required this.dialogType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 1,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).highlightColor,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: const Offset(0.0, 0.0),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dialogType != DialogType.none)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RepaintBoundary(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.2, end: 1.0),
                        duration: Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, _) {
                          return Transform.scale(
                            scale: value,
                            child: _getIcon(),
                          );
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Image _getIcon() {
    String iconName;
    switch (dialogType) {
      case DialogType.info:
        iconName = "info";
        break;
      case DialogType.error:
        iconName = "error";
        break;
      case DialogType.announcment:
        iconName = "bell";
        break;
      default:
        iconName = "error";
    }

    return Image.asset(
      "icons/$iconName.png",
      package: "dialog_service",
      width: 100,
      height: 100,
    );
  }
}
