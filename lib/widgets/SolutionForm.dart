import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/GlpiApi.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:flutter_app/models/Solution.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SolutionForm extends StatefulWidget {

  final int _ticketid;

  SolutionForm(this._ticketid);

  @override
  createState() => new SolutionFormState();
}

class SolutionFormState extends State<SolutionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlpiApi api = GlpiApi();

  String _content;
  String _solutiontype;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //   Settings.current_context = context;
    return (widget._ticketid == 0
        ? new Text(AppLocalizations.of(context).errorSolution)
        : new SingleChildScrollView ( child: new Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top:20, left:10.0, right:10),
                    child:  DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      hint: Text(AppLocalizations.of(context).solutionType), // Not necessary for Option 1
                      value: _solutiontype,
                      onChanged: (newValue) {
                        setState(() {
                          _solutiontype = newValue;
                        });
                      },
                      items: Settings.SolutionTypes.map((data) {
                        return DropdownMenuItem<String>(
                          child: new Text(data),
                          value: data,
                        );
                      }).toList(),
                    )),
                Padding(
                    padding: EdgeInsets.only(top:16, left:10.0, right:10),
                    child: TextFormField(
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
//                    hintText: 'Enter your email',
                        labelText:
                            AppLocalizations.of(context).solutionContent + " *",
//                     errorText: 'Error message',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).required;
                        }
                        _content = value;
                        return null;
                      },
                    )),

                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          _addSolution();
                          // Process data.
                        }
                      },
                      child: Text(AppLocalizations.of(context).save),
                    ))
              ],
            ))) );
  }

  Future<void> _addSolution() async {

    Solution _solution = new Solution();
    _solution.content = _content;
    _solution.items_id = widget._ticketid;
    _solution.solutiontypes_id=Settings.SolutionTypesByName[_solutiontype]==null ? 0 : Settings.SolutionTypesByName[_solutiontype].id;

    api.addSolution(_solution).then((string) {

       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(string == ""
                  ? AppLocalizations.of(context).solution_added
                  : AppLocalizations.of(context).solution_adding_error +
                      " " +
                      string),
              backgroundColor: string == "" ? Colors.green : Colors.red));

       if (string == "") {
         FocusScope.of(context).unfocus();
         Navigator.pop(context,true);
       }

    });
  }
}
