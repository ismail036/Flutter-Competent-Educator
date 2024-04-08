

class Book{
  String imgLink;
  String name;
  String desc;
  bool isFavorite;
  String detailPageLink;

  Book(this.imgLink,this.name,this.desc,this.isFavorite,this.detailPageLink);

  Map<String, dynamic> toMap() {
    return {
      'imgLink': imgLink,
      'name': name,
      'desc': desc,
      'isFavorite': isFavorite,
      'detailPageLink': detailPageLink,
    };
  }


}