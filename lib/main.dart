import 'package:flutter/material.dart';
import 'package:markdown_lite_editor/markdown_lite_editor.dart';

import 'theme/theme.dart';

void main() {
  runApp(const Poodoo());
}

class Poodoo extends StatelessWidget {
  const Poodoo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // themeMode: ThemeMode.light,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(children: [Expanded(child: Editor())]),
        ),
      ),
    );
  }
}

class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final _controller = MarkdownTextEditingController(text: _exampleMarkdown);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: MarkdownLiteEditor(controller: _controller)),
        VerticalDivider(),
        Expanded(
          child: SingleChildScrollView(
            child: RichText(
              text: _controller.buildTextSpan(
                context: context,
                style: Theme.of(context).textTheme.bodyMedium!,
                withComposing: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _exampleMarkdown = '''
# Heading 1 with **bold** and *italic*
Simple paragraph with **bold** and *italic* text.

## Heading 2: Nested Inline Styles
**Bold with *italic* inside**, ***bold and italic***, and ~~strike with **bold**~~.

### Heading 3: Links with Styles [link](https://example.com)
Here is a [**bold link**](https://example.com) and [*italic link*](https://example.com) [`code link`](https://example.com).

Simple link https://example.com and github.com.

https://valentinvignal.github.io/portfolio/

https://pub.dev/

https://ticktick.com/webapp/#p/68ec6f368f085bf4def5f8eb/tasks/6927bfc5d95aea4fb8d13f98

https://www.notion.so/TODO-12f210b82c3080cbb8d0f0b36288c16e

https://web.whatsapp.com/

https://web.telegram.org

https://www.youtube.com/

https://tasksboard.com/app

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

# Heading End''';
