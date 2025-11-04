import 'package:flutter/material.dart';
import 'package:markdown_lite/markdown_lite.dart' as md;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: MarkdownTextField()));
  }
}

class MarkdownTextField extends StatefulWidget {
  const MarkdownTextField({super.key});

  @override
  State<MarkdownTextField> createState() => _MarkdownTextFieldState();
}

class _MarkdownTextFieldState extends State<MarkdownTextField> {
  final _controller = MarkdownTextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller, maxLines: null, expands: true);
  }
}

const _exampleMarkdown = '''
# Heading 1
Here is some **bold text**, some *italic text*, and some ~~strikethrough~~.

## Heading 2
Inline code: `print("Hello, World!")`
```
// Block code:
void main() {
  print("Hello, World!");
}
```

> This is a blockquote.

- Unordered list item 1
- Unordered list item 2

1. Ordered list item 1
2. Ordered list item 2

- [x] Checked item
- [ ] Unchecked item

Plain text paragraph to demonstrate styling.

Here is a [link](https://example.com).


''';

class MarkdownTextEditingController extends TextEditingController {
  MarkdownTextEditingController({String? text})
    : super(text: text ?? _exampleMarkdown);
  TextStyle _baseStyle(BuildContext context, TextStyle? style) {
    // Fallback to DefaultTextStyle if incoming style is null.
    return style ?? DefaultTextStyle.of(context).style;
  }

  TextStyle _headingStyle(TextStyle base, int level) {
    final baseSize = base.fontSize ?? 14.0;
    // Simple scaling for headings within a TextField context.
    return base.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: switch (level) {
        1 => baseSize * 1.6,
        2 => baseSize * 1.45,
        3 => baseSize * 1.3,
        4 => baseSize * 1.2,
        5 => baseSize * 1.1,
        _ => baseSize * 1.05,
      },
    );
  }

  TextStyle _bold(TextStyle base) =>
      base.merge(const TextStyle(fontWeight: FontWeight.w700));
  TextStyle _italic(TextStyle base) =>
      base.merge(const TextStyle(fontStyle: FontStyle.italic));
  TextStyle _strike(TextStyle base) =>
      base.merge(const TextStyle(decoration: TextDecoration.lineThrough));
  TextStyle _inlineCode(BuildContext context, TextStyle base) {
    final theme = Theme.of(context);
    return base.merge(
      TextStyle(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
          0.6,
        ),
      ),
    );
  }

  TextStyle _codeBlock(BuildContext context, TextStyle base) {
    final theme = Theme.of(context);
    return base.merge(
      TextStyle(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }

  TextStyle _linkStyle(BuildContext context, TextStyle base) {
    final theme = Theme.of(context);
    return base.merge(
      TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }

  TextStyle _blockquoteStyle(BuildContext context, TextStyle base) {
    final theme = Theme.of(context);
    return base.merge(
      TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.75),
        fontStyle: FontStyle.italic,
      ),
    );
  }

  // Build TextSpans for a full markdown document.
  List<InlineSpan> _buildDocumentSpans(
    BuildContext context,
    TextStyle base,
    List<md.AstNode> nodes,
  ) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      // Insert one newline between non-blank nodes to reflect original line breaks.
      if (i > 0 && node is! md.BlankLineNode) {
        spans.add(TextSpan(text: '\n', style: base));
      }
      spans.addAll(_visitNode(context, base, node));
    }
    return spans;
  }

  // Visitor that returns a list of spans for the given node.
  List<InlineSpan> _visitNode(
    BuildContext context,
    TextStyle base,
    md.AstNode node,
  ) {
    switch (node) {
      // Headings
      case md.H1Node() ||
          md.H2Node() ||
          md.H3Node() ||
          md.H4Node() ||
          md.H5Node() ||
          md.H6Node():
        final level = (node as md.HeadingNode).level;
        final style = _headingStyle(base, level);
        // Use rawText to keep the user's exact characters visible while styling.
        return [TextSpan(text: node.rawText, style: style)];

      // Paragraphs
      case md.ParagraphNode(:final children):
        final paragraphSpans = <InlineSpan>[];
        for (final child in children) {
          paragraphSpans.addAll(_visitNode(context, base, child));
        }
        return paragraphSpans.isEmpty
            ? [TextSpan(text: node.rawText, style: base)]
            : paragraphSpans;

      // Unordered list
      case md.UnorderedListNode(:final items):
        final listSpans = <InlineSpan>[];
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final bullet = '• ';
          listSpans.add(TextSpan(text: bullet, style: base));
          listSpans.addAll(_visitNode(context, base, item));
          if (i < items.length - 1) {
            listSpans.add(TextSpan(text: '\n', style: base));
          }
        }
        return listSpans;

      // Ordered list
      case md.OrderedListNode(:final items):
        final listSpans = <InlineSpan>[];
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          final marker = '${i + 1}. ';
          listSpans.add(TextSpan(text: marker, style: base));
          listSpans.addAll(_visitNode(context, base, item));
          if (i < items.length - 1) {
            listSpans.add(TextSpan(text: '\n', style: base));
          }
        }
        return listSpans;

      // List item
      case md.ListItemNode(:final children, :final isChecked):
        final spans = <InlineSpan>[];
        if (isChecked != null) {
          spans.add(TextSpan(text: isChecked ? '☑ ' : '☐ ', style: base));
        }
        if (children.isEmpty) {
          // Fallback to rawText if no parsed inline children.
          spans.add(TextSpan(text: node.rawText, style: base));
        } else {
          for (final child in children) {
            spans.addAll(_visitNode(context, base, child));
          }
        }
        return spans;

      // Code block
      case md.CodeBlockNode(:final text):
        return [TextSpan(text: text, style: _codeBlock(context, base))];
      // Blank line
      case md.BlankLineNode():
        return [TextSpan(text: '\n', style: base)];

      // Blockquote
      case md.BlockquoteNode(:final children):
        final qStyle = _blockquoteStyle(context, base);
        // Simple prefix for blockquote lines; maintain readability in TextField.
        final quoteChildren = <InlineSpan>[];
        for (final child in children) {
          quoteChildren.addAll(_visitNode(context, qStyle, child));
          quoteChildren.add(TextSpan(text: '\n', style: qStyle));
        }
        if (quoteChildren.isNotEmpty) quoteChildren.removeLast();
        // Prefix with a vertical bar to suggest quote.
        return [TextSpan(text: '│ ', style: qStyle), ...quoteChildren];

      // Inline styles
      case md.BoldNode():
        return [TextSpan(text: node.rawText, style: _bold(base))];
      case md.ItalicNode():
        return [TextSpan(text: node.rawText, style: _italic(base))];
      case md.StrikethroughNode():
        return [TextSpan(text: node.rawText, style: _strike(base))];
      case md.InlineCodeNode():
        return [
          TextSpan(text: node.rawText, style: _inlineCode(context, base)),
        ];
      case md.LinkNode():
        // Style link text; keep raw to preserve markdown syntax in-place.
        return [TextSpan(text: node.rawText, style: _linkStyle(context, base))];

      // Plain text
      case md.TextNode():
        return [TextSpan(text: node.rawText, style: base)];

      // No fallback necessary; all node variants are covered.
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = _baseStyle(context, style);

    // Parse markdown into AST using markdown_lite.
    final nodes = md.parse(text);

    // Build styled spans for entire document.
    final children = _buildDocumentSpans(context, base, nodes);

    // Note: For simplicity, composing underlines are not re-applied here.
    // Flutter gracefully handles composing without explicit styling in many cases,
    // and adding it would require splitting spans at composing boundaries.
    // This can be enhanced later if needed.
    return TextSpan(style: base, children: children);
  }
}
