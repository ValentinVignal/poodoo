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
# Heading 1 with **bold** and *italic*
Here is some **bold text**, some *italic text*, and some ~~strikethrough~~.

## Heading 2: Nested Inline Styles
**Bold with *italic* inside**, ***bold and italic***, and ~~strike with **bold**~~.

### Heading 3: Links with Styles [link](https://example.com)
Here is a [**bold link**](https://example.com) and [*italic link*](https://example.com).

Inline code: `print("Hello, World!")`
```dart
// Block code:
void main() {
  print("Hello, World!");
}
```

> This is a blockquote with **bold** and *italic* text.
> It can span multiple lines.

- Unordered list with **bold item**
- *Italic item* with ~~strikethrough~~
- Regular item with [link](https://example.com)

1. Ordered list with ***bold italic***
2. Item with `inline code`
3. Item with nested **bold and *italic* mixed**

- [x] Checked item with **bold**
- [ ] Unchecked item with *italic*

Plain text paragraph to demonstrate styling.

**Nesting examples:**
- **Bold only**
- *Italic only*
- ***Bold and italic***
- **Bold with *nested italic* inside**
- *Italic with **nested bold** inside*
- ~~Strikethrough with **bold** and *italic*~~


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
      // Headings: show all rawText, just style
      case md.HeadingNode():
        final heading = node;
        final level = heading.level;
        final style = _headingStyle(base, level);
        return [TextSpan(text: node.rawText, style: style)];

      // Paragraphs: show all rawText
      case md.ParagraphNode():
        return [TextSpan(text: node.rawText, style: base)];

      // Unordered list: show all rawText
      case md.UnorderedListNode():
        return [TextSpan(text: node.rawText, style: base)];

      // Ordered list: show all rawText
      case md.OrderedListNode():
        return [TextSpan(text: node.rawText, style: base)];

      // List item: show all rawText
      case md.ListItemNode():
        return [TextSpan(text: node.rawText, style: base)];

      // Code block
      case md.CodeBlockNode(:final text):
        return [TextSpan(text: text, style: _codeBlock(context, base))];
      // Blank line
      case md.BlankLineNode():
        return [TextSpan(text: '\n', style: base)];

      // Blockquote: show all rawText
      case md.BlockquoteNode():
        final qStyle = _blockquoteStyle(context, base);
        return [TextSpan(text: node.rawText, style: qStyle)];

      // Inline styles: show all rawText, just style
      case md.BoldNode():
        final boldStyle = _bold(base);
        return [TextSpan(text: node.rawText, style: boldStyle)];
      case md.ItalicNode():
        final italicStyle = _italic(base);
        return [TextSpan(text: node.rawText, style: italicStyle)];
      case md.StrikethroughNode():
        final strikeStyle = _strike(base);
        return [TextSpan(text: node.rawText, style: strikeStyle)];
      case md.InlineCodeNode():
        return [
          TextSpan(text: node.rawText, style: _inlineCode(context, base)),
        ];
      case md.LinkNode():
        final linkStyle = _linkStyle(context, base);
        return [TextSpan(text: node.rawText, style: linkStyle)];

      // Plain text
      case md.TextNode():
        return [TextSpan(text: node.rawText, style: base)];
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
