abstract class Tag {
  final String text;
  Tag(this.text);
}

class GeneralTag extends Tag {
  GeneralTag(String text) : super(text);
}

// class BoxTag extends Tag {
//   final double x1, y1, x2, y2; // Coordinates relative to the card
//   BoxTag(String text, this.x1, this.y1, this.x2, this.y2) : super(text);
// }
