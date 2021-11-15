//import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
//part 'followup.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
//@JsonSerializable()

class Followup {
  int id;
  int is_private;
  String content;
  String date_creation;
  String users_id;
  static final String itemtype = "Ticket";
  Object items_id;

  // "entities_id":0,"name":"name 1","date":"2021-02-13 12:00:00","closedate":null,"solvedate":null,"date_mod":"2021-02-13 11:33:52","users_id_lastupdater":6,"status":2,"users_id_recipient":6,"requesttypes_id":1,"content":"&lt;p&gt;test 1&lt;/p&gt;","urgency":3,"impact":3,"priority":3,"itilcategories_id":0,"type":1,

  Followup();

  Followup.fromJson(Map<String, dynamic> json)
      : is_private = json['is_private'],
        content = json['content'],
        id = json['id'],
        date_creation = json['date_creation'],
        users_id = json['users_id'],
        items_id = json['items_id'];

  Map<String, dynamic> toJson() => {
        'is_private': is_private,
        'content': content,
        'items_id': items_id,
        'itemtype': itemtype,
      };

  @override
  String toString() => 'Followup { id: $id }';
}

/*
    @SerializedName("id")
    private int mId;

    @SerializedName("is_private")
    private int mPrivate;

    public int getPrivate() {
        return mPrivate;
    }

    public void setPrivate(int pr) {
        mPrivate = pr;
    }

    @SerializedName("date_creation")
    private String mDateCreation;

    @SerializedName("content")
    private String mContent;

    @SerializedName("users_id")
    private String mUser;
    public String getUserId() {
        return mUser;
    }
 */
