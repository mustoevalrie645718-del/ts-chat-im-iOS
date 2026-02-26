import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';
import 'package:html_unescape_xx/html_unescape.dart';

/// message content: @uid1 @uid2 xxxxxxx
///

/// Get the phone number validator instance
PhoneNumberValidator get _phoneValidator => PhoneNumberValidator();

enum TextModel { match, normal }

class MatchTextView extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextStyle? matchTextStyle;
  final InlineSpan? prefixSpan;

  /// isReceived ? TextAlign.left : TextAlign.right
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final double textScaleFactor;

  /// all user info
  /// key:userid
  /// value:username
  final Map<String, String> allAtMap;
  final List<MatchPattern> patterns;
  final TextModel model;
  final Function(String? text)? onVisibleTrulyText;
  final bool isSupportCopy;
  final FocusNode? copyFocusNode;

  // final TextAlign textAlign;
  const MatchTextView(
      {Key? key,
      required this.text,
      this.allAtMap = const <String, String>{},
      this.prefixSpan,
      this.patterns = const <MatchPattern>[],
      this.textAlign = TextAlign.left,
      this.overflow = TextOverflow.clip,
      this.textStyle,
      this.matchTextStyle,
      this.maxLines,
      this.textScaleFactor = 1.0,
      this.model = TextModel.match,
      this.onVisibleTrulyText,
      this.isSupportCopy = false,
      this.copyFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> children = <InlineSpan>[];

    if (prefixSpan != null) children.add(prefixSpan!);

    if (model == TextModel.normal) {
      _normalModel(children);
    } else {
      _matchModel(children);
    }

    // 复制@消息直接使用不在重复解析
    final textSpan = TextSpan(children: children);
    onVisibleTrulyText?.call(textSpan.toPlainText());

    var text = Text.rich(
      textSpan,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      textScaler: TextScaler.linear(textScaleFactor),
    );
    return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: isSupportCopy ? SelectionArea(focusNode: copyFocusNode, child: text) : text);
  }

  _normalModel(List<InlineSpan> children) {
    children.add(TextSpan(text: text, style: textStyle));
  }

  _matchModel(List<InlineSpan> children) {
    final mappingMap = <String, MatchPattern>{};

    for (var e in patterns) {
      if (e.type == PatternType.at) {
        mappingMap[regexAt] = e;
        mappingMap[regexAtAll] = MatchPattern(type: PatternType.atAll);
      } else if (e.type == PatternType.email) {
        mappingMap[regexEmail] = e;
      } else if (e.type == PatternType.mobile) {
        mappingMap[regexMobile] = e;
      } else if (e.type == PatternType.tel) {
        mappingMap[regexTel] = e;
      } else if (e.type == PatternType.url) {
        mappingMap[regexUrl] = e;
      } else {
        mappingMap[e.pattern!] = e;
      }
    }

    var regexEmoji = emojiFaces.keys.toList().join('|').replaceAll('[', '\\[').replaceAll(']', '\\]');

    mappingMap[regexEmoji] = MatchPattern(type: PatternType.email);

    String pattern;

    if (mappingMap.length > 1) {
      pattern = '(${mappingMap.keys.toList().join('|')})';
    } else {
      pattern = regexEmoji;
    }

    stripHtmlIfNeeded(text).splitMapJoin(
      RegExp(pattern),
      onMatch: (Match match) {
        var matchText = match[0]!;
        InlineSpan inlineSpan;
        final mapping = mappingMap[matchText] ??
            mappingMap[mappingMap.keys.firstWhere((element) {
              final reg = RegExp(element);
              return reg.hasMatch(matchText);
            }, orElse: () {
              return '';
            })];
        if (mapping != null) {
          if (mapping.type == PatternType.at) {
            String userID = matchText.replaceFirst("@", "").trim();
            if (allAtMap.containsKey(userID)) {
              matchText = '@${allAtMap[userID]} ';
              inlineSpan = TextSpan(
                text: matchText,
                style: mapping.style ?? matchTextStyle ?? textStyle,
                recognizer: mapping.onTap == null
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () => mapping.onTap!(_getUrl(userID, mapping.type), mapping.type)),
              );
            } else {
              inlineSpan = TextSpan(text: matchText, style: textStyle);
            }
          } else if (mapping.type == PatternType.atAll) {
            matchText = '@${StrRes.everyone} ';
            inlineSpan = TextSpan(
              text: matchText,
              style: mapping.style ?? matchTextStyle ?? textStyle,
            );
          }
          /* else if (mapping.type == PatternType.EMOJI) {
            inlineSpan = ImageSpan();
          } */
          else if (mapping.type == PatternType.mobile || mapping.type == PatternType.tel) {
            // For phone numbers, validate using PhoneNumberValidator
            if (_phoneValidator.isValidSync(matchText)) {
              inlineSpan = TextSpan(
                text: matchText.split('').join('\u200B'),
                style: mapping.style ?? matchTextStyle ?? textStyle,
                recognizer: mapping.onTap == null
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () => mapping.onTap!(_getUrl(matchText, mapping.type), mapping.type)),
              );
            } else {
              // Invalid phone number, render as normal text
              inlineSpan = TextSpan(text: matchText, style: textStyle);
            }
          } else {
            inlineSpan = TextSpan(
              text: matchText.split('').join('\u200B'),
              style: mapping.style ?? matchTextStyle ?? textStyle,
              recognizer: mapping.onTap == null
                  ? null
                  : (TapGestureRecognizer()
                    ..onTap = () => mapping.onTap!(_getUrl(matchText, mapping.type), mapping.type)),
            );
          }
        } else {
          inlineSpan = TextSpan(text: matchText, style: textStyle);
        }
        children.add(inlineSpan);
        return '';
      },
      onNonMatch: (text) {
        children.add(TextSpan(text: text, style: textStyle));
        return '';
      },
    );
  }

  _getUrl(String text, PatternType type) {
    switch (type) {
      case PatternType.url:
        return text.substring(0, 4) == 'http' ? text : 'http://$text';
      case PatternType.email:
        return text.substring(0, 7) == 'mailto:' ? text : 'mailto:$text';
      case PatternType.tel:
      case PatternType.mobile:
        return text.substring(0, 4) == 'tel:' ? text : 'tel:$text';
      default:
        return text;
    }
  }

  String stripHtmlIfNeeded(String text) {
    final unescape = HtmlUnescapeAll();

    return text.replaceAllMapped(
      RegExp(
        r'<([a-zA-Z][a-zA-Z0-9]*)(?:\s+[^>]*)?/?>'
        r'|</([a-zA-Z][a-zA-Z0-9]*)>'
        r'|&[a-zA-Z]+;|&#[0-9]+;',
        multiLine: true,
      ),
      (match) {
        if (match.group(1) == null && match.group(2) == null) {
          return unescape.convert(match.group(0)!);
        }

        final tagName = match.group(1) ?? match.group(2) ?? '';
        final commonTags = {
          'div',
          'span',
          'p',
          'br',
          'b',
          'i',
          'u',
          'strong',
          'em',
          'a',
          'img',
          'table',
          'tr',
          'td',
          'th',
          'ul',
          'ol',
          'li',
          'h1',
          'h2',
          'h3',
          'h4',
          'h5',
          'h6',
          'script',
          'style',
          'meta',
          'link',
          'title',
          'head',
          'body',
          'html',
          'doctype'
        };

        if (commonTags.contains(tagName.toLowerCase())) {
          return ' ';
        }

        return match.group(0)!;
      },
    ).trim();
  }
}

class MatchPattern {
  PatternType type;

  String? pattern;

  TextStyle? style;

  Function(String link, PatternType? type)? onTap;

  MatchPattern({required this.type, this.pattern, this.style, this.onTap});
}

enum PatternType { at, atAll, email, mobile, tel, url, emoji, custom }

/// 空格@uid空格
const regexAt = r"@(?:\d+|[a-zA-Z_][a-zA-Z0-9_]*)";

const regexAtAll = r'@AtAllTag ';

/// Email Regex - A predefined type for handling email matching
const regexEmail = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";

/// URL Regex - A predefined type for handling URL matching
const regexUrl =
    r"((http|https):\/\/)(([a-zA-Z0-9@:._\+-~#=]{2,256}\.[a-z]{2,6})|(\d{1,3}(\.\d{1,3}){3}))(:\d+)?(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?";

/// Phone Regex - A predefined type for handling phone matching
// const regexMobile =
//     r"(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})";

/// Regex of exact mobile.
const String regexMobile =
    '^(\\+?86)?((13[0-9])|(14[57])|(15[0-35-9])|(16[2567])|(17[01235-8])|(18[0-9])|(19[1589]))\\d{8}\$';

/// Regex of telephone number.
const String regexTel = '^0\\d{2,3}[-]?\\d{7,8}';

const emojiFaces = <String, String>{'[]': '[]'};
