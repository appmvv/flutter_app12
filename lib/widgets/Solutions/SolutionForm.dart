import 'package:flutter/material.dart';
import 'package:flutter_app/models/Settings.dart';
import 'package:flutter_app/providers/SolutionsProvider.dart';
import 'package:flutter_app/providers/TicketProvider.dart';
import 'package:flutter_app/providers/TicketsProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SolutionForm extends StatefulWidget {

  final int? _ticketId;

  SolutionForm(this._ticketId);

  @override
  createState() => new SolutionFormState();
}

class SolutionFormState extends State<SolutionForm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _content;
  String? _solutiontype;

  @override
  Widget build(BuildContext context) {
    //   Settings.current_context = context;
    return SingleChildScrollView ( child: new Form(
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
                      hint: Text(AppLocalizations.of(context)!.solutionType), // Not necessary for Option 1
                      value: _solutiontype,
                      onChanged: (newValue) {
                        setState(() {
                          _solutiontype = newValue;
                        });
                      },
                      items: Settings.SolutionTypes.map((data) {
                        return DropdownMenuItem<String>(
                          child: new Text(data!),
                          value: data,
                        );
                      }).toList(),
                    )),
                Padding(
                    padding: EdgeInsets.only(top:16, left:10.0, right:10,bottom:16),
                    child: TextFormField(
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
//                    hintText: 'Enter your email',
                        labelText:
                            AppLocalizations.of(context)!.solutionContent + " *",
//                     errorText: 'Error message',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.required;
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
                        if (_formKey.currentState!.validate()) {

                          _addSolution();
                          // Process data.
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.save),
                    ))
              ],
            ))) ;
  }

  Future<void> _addSolution() async {

    Provider.of<SolutionsProvider>(context, listen: false).addSolution(widget._ticketId, _content, _solutiontype)
        .then((string) {
      if (string == "") {
        Provider.of<SolutionsProvider>(context, listen: false).getSolutions(widget._ticketId);
        Provider.of<TicketProvider>(context, listen: false).getTicket(widget._ticketId);
        if (Settings.notSolvedOnly) Provider.of<TicketsProvider>(context, listen: false).getTickets();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text( AppLocalizations
                .of(context)!
                .solution_adding_error +
                " " +
                string),
            backgroundColor: Colors.red));
      }
    });
  }


}

