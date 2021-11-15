import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FollowupMessage extends StatefulWidget {

  final int _ticketid;
  final Function callback;

  FollowupMessage(this._ticketid, this.callback);

  @override
  createState() => new FollowupMessageState(_ticketid);
}

class FollowupMessageState extends State<FollowupMessage> {
//  final _formKey = GlobalKey<FormState>();

  GlpiApi api = GlpiApi();
  int _ticketid;
  bool _is_private = false;

  FollowupMessageState(ticketid) {
    _ticketid = ticketid;
  }

  TextEditingController _content;
  bool _sendEnabled = false;

  @override
  void initState() {
    super.initState();
    _content = TextEditingController();
  }

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4, top: 10, bottom: 5, right: 15),
      height: MediaQuery.of(context).size.height * 0.2,
      // set height to 40% of the screen height
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: Colors.blue,
        ),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      child: new Table(columnWidths: {
        0: FractionColumnWidth(.1),
        1: FractionColumnWidth(.8),
        2: FractionColumnWidth(.1)
      }, children: [
        new TableRow(children: [
          IconButton(
            icon: Icon(Icons.lock),
            color: Colors.black.withOpacity(_is_private ? 1 : 0.3),
            onPressed: () {
              setState(() {
                _is_private = !_is_private;
              });
            },
          ),
          new Padding(
            padding: EdgeInsets.all(5.0),
            child: TextField(
              controller: _content,
              maxLines: 4,
              onChanged: (text) {
                setState(() {
                  _sendEnabled = text.trim().length > 0;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: AppLocalizations.of(context).followup_message,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendEnabled ? () => _addFollowup() : null,
          ),
        ])
      ])
    );

  }

  Future<void> _addFollowup() async {

    api.addFollowup(_ticketid, _content.text, _is_private).then((string) {
      //     if (list.isEmpty) {
      if (string == "") {
        setState(() {
          _content.text = "";
          _is_private = false;
          _sendEnabled = false;
          FocusScope.of(context).unfocus();
        });

        widget.callback();

      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(string == ""
              ? AppLocalizations.of(context).followup_added
              : AppLocalizations.of(context).followup_adding_error+" "+string),
          backgroundColor: string == "" ? Colors.green : Colors.red));

    });

  }
}
