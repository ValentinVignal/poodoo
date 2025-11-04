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

  TextStyle? _headingStyle(BuildContext context, int level) {
    return switch (level) {
      1 => Theme.of(context).textTheme.headlineLarge,
      2 => Theme.of(context).textTheme.headlineMedium,
      3 => Theme.of(context).textTheme.headlineSmall,
      4 => Theme.of(context).textTheme.titleLarge,
      5 => Theme.of(context).textTheme.titleMedium,
      6 => Theme.of(context).textTheme.titleSmall,
      _ => null,
    };
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

  // Build spans with nested styling by finding child positions in parent's rawText
  List<InlineSpan> _buildNestedSpans(
    BuildContext context,
    TextStyle base,
    String rawText,
    List<md.AstNode> children,
  ) {
    if (children.isEmpty) {
      return [TextSpan(text: rawText, style: base)];
    }

    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final child in children) {
      // Find where this child's rawText appears in the parent's rawText
      final childStart = rawText.indexOf(child.rawText, lastEnd);
      if (childStart == -1) continue;

      // Add any text before this child
      if (childStart > lastEnd) {
        spans.add(
          TextSpan(text: rawText.substring(lastEnd, childStart), style: base),
        );
      }

      // Add the child with its styling
      spans.addAll(_visitNode(context, base, child));

      lastEnd = childStart + child.rawText.length;
    }

    // Add any remaining text after the last child
    if (lastEnd < rawText.length) {
      spans.add(TextSpan(text: rawText.substring(lastEnd), style: base));
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
      // Headings: show rawText with heading style and nested children
      case md.HeadingNode():
        final heading = node;
        final level = heading.level;
        final style = _headingStyle(context, level) ?? base;
        return _buildNestedSpans(
          context,
          style,
          node.rawText,
          heading.children,
        );

      // Paragraphs: show rawText with nested children
      case md.ParagraphNode(:final children):
        return _buildNestedSpans(context, base, node.rawText, children);

      // Unordered list: show rawText with nested items
      case md.UnorderedListNode(:final items):
        return _buildNestedSpans(context, base, node.rawText, items);

      // Ordered list: show rawText with nested items
      case md.OrderedListNode(:final items):
        return _buildNestedSpans(context, base, node.rawText, items);

      // List item: show rawText with nested children
      case md.ListItemNode(:final children):
        return _buildNestedSpans(context, base, node.rawText, children);

      // Code block: show rawText including ```
      case md.CodeBlockNode():
        return [TextSpan(text: node.rawText, style: _codeBlock(context, base))];
      // Blank line
      case md.BlankLineNode():
        return [TextSpan(text: '\n', style: base)];

      // Blockquote: show rawText with nested children
      case md.BlockquoteNode(:final children):
        final qStyle = _blockquoteStyle(context, base);
        return _buildNestedSpans(context, qStyle, node.rawText, children);

      // Inline styles: show rawText with style and nested children
      case md.BoldNode(:final children):
        final boldStyle = _bold(base);
        return _buildNestedSpans(context, boldStyle, node.rawText, children);
      case md.ItalicNode(:final children):
        final italicStyle = _italic(base);
        return _buildNestedSpans(context, italicStyle, node.rawText, children);
      case md.StrikethroughNode(:final children):
        final strikeStyle = _strike(base);
        return _buildNestedSpans(context, strikeStyle, node.rawText, children);
      case md.InlineCodeNode():
        return [
          TextSpan(text: node.rawText, style: _inlineCode(context, base)),
        ];
      case md.LinkNode(:final children):
        final linkStyle = _linkStyle(context, base);
        return _buildNestedSpans(context, linkStyle, node.rawText, children);

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
