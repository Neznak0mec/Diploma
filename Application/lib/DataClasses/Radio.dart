class MyRadio{
  String name;
  String url;
  MyRadio({required this.name, required this.url});

  static fromJson(e) {
    return MyRadio(
      name: e['name'],
      url: e['url']
    );
  }

  String ShortUrl(){
    return url.split("://")[1].split('/')[0];
  }

}