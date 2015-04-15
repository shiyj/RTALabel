RTALabel 
=======

RTALabel is a rich text parser for UILabel to use html-like markups by using the Foundation's `NSAttributedString`.

Usage
-----

copy all the files in `Lib` dir into your xcode project,

then set a UILabel's attribute string with html-like text like this:

```
#import "UILabel+RichText.h"
...
@property (weak, nonatomic) IBOutlet UILabel *renderLabel;
...

NSString *str = "<attr color=#FF0000>Nest label:<b size=40 color=#00FF00>Bold</b> <i size=40 color=#0000FF>Italic</i></attr>",
[self.renderLabel setRichAttributedText:str];
```
here is the result:

![](rtalabel_main.png) 

support labels and attributes
-----

now,RTALabel support labels below:

* b => bold font
* i => italic font
* attr => a flag for RTALabel to parse it's attributes
* u => underline
* del => delete line or Strikethrough line
* p => Paragraph style label

and attributes:

* color
* size
* lineColor(only `u` and `del` label support this attribute)
* lineSpace(only `p` label support this attribute)
* indent(only `p` label support this attribute)
* paragraphSpacing(only `p` label support this attribute)
