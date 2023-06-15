
class Solution {

  int? id;
  String? date_creation;
  String?  content;
  Object? items_id;
  static final String itemtype = "Ticket";
  int? users_id;
  Object? user_name;
  int? solutiontypes_id;
  Object? solutiontype_name;

  //Solution({@required this.id, this.date_creation, this.content, this.items_id, this.itemtype, this.users_id, this.user_name, this.solutiontypes_id, this.solutiontype_name});
  Solution();

 Solution.fromJson(Map<String, dynamic> json)
      : id=json['id'],
      date_creation=json['date_creation'],
      content =json['content'],
      items_id=json['items_id'],
      users_id=json['users_id'],
      user_name=json['user_name'],
      solutiontypes_id=json['solutiontypes_id'],
      solutiontype_name=json['solutiontype_name'];

  Map<String, dynamic> toJson() => {
    'content': content,
    'items_id': items_id,
    'itemtype': itemtype,
    'solutiontypes_id': solutiontypes_id,
  };


  @override
  String toString() => 'Solution $id';

}