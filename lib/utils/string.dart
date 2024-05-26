
void main(List<String> args) {
  print(splitstring("(quantity=3,total=30)"));

  // var a = 5;
  // var b = 7;
  // b = b - a; // b = 2
  // a = b + a; // a = 7
  swap(10, 20);
}

List<int> splitstring(String str) {
  var result = str.substring(1, str.length - 1);
  List<String> finalresult = result.split(",");
  int? total;
  int? quantity;
  for (var element in finalresult) {
    List<String> splitelement = element.split("=");
    if (splitelement[0].trim() == "total") {
      total = int.parse(splitelement[1]);
    } else if (splitelement[0].trim() == "quantity") {
      quantity = int.parse(splitelement[1]);
    }
  }
  return [quantity!, total!];
}

void swap(int x, int y) {
  x = x + y;
  y = x - y;
  x = x - y;
  print("x = $x, y = $y");
}
