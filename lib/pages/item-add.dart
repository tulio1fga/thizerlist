import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'package:thizerlist/application.dart';
import 'package:thizerlist/layout.dart';
import 'items.dart';

import 'package:thizerlist/models/Item.dart';

import 'package:thizerlist/utils/QuantityFormatter.dart';

class ItemAddPage extends StatefulWidget {

  static String tag = 'page-item-add';

  @override
  _ItemAddPageState createState() => _ItemAddPageState();
}

class _ItemAddPageState extends State<ItemAddPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cName = TextEditingController();
  final TextEditingController _cQtd = TextEditingController(text: '1');
  final MoneyMaskedTextController _cValor =MoneyMaskedTextController(
    thousandSeparator: '.',
    decimalSeparator: ',',
    leftSymbol: 'R\$ '
  );

  String selectedUnit = unity.keys.first;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {

    final inputName = TextFormField(
      controller: _cName,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Nome do item',
        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5)
        )
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Obrigatório';
        }
        return null;
      },
    );

    final inputQuantidade = TextFormField(
      controller: _cQtd,
      autofocus: false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Quantidade',
        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5)
        )
      ),
      inputFormatters: [new QuantityFormatter(precision: unity[selectedUnit])],
      validator: (value) {

        double valueAsDouble = (double.tryParse(value) ?? 0.0);

        if (valueAsDouble <= 0) {
          return 'Informe um número positivo';
        }
        return null;
      },
    );

    final inputUnit = DropdownButton<String>(
      value: selectedUnit,
      onChanged: (String newValue) {
        setState(() {

          double valueAsDouble = (double.tryParse(inputQuantidade.controller.text) ?? 0.0);
          inputQuantidade.controller.text = valueAsDouble.toStringAsFixed(unity[newValue]);

          selectedUnit = newValue;
        });
      },
      items: unity.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    final inputValor = TextFormField(
      controller: _cValor,
      autofocus: false,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: 'Valor R\$',
        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5)
        )
      ),
      validator: (value) {
        if (currencyToDouble(value) < 0.0) {
          return 'Obrigatório';
        }
        return null;
      },
    );

    Container content = Container(
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'Adicionar Item',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24
              ),
            ),
            SizedBox(height: 10),
            Text('Nome do item'),
            inputName,
            SizedBox(height: 10),
            Text('Quantidade'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width -150,
                  child: inputQuantidade,
                ),
                Container(width: 100, child:  inputUnit)
              ]
            ),
            SizedBox(height: 10),
            Text('Valor'),
            inputValor,
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  activeColor: Layout.primary(),
                  onChanged: (bool value) {
                    setState(() {
                      isSelected = value;
                    });
                  },
                  value: isSelected,
                ),
                GestureDetector(
                  child: Text('Já está no carrinho?', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    setState(() {
                      isSelected = !isSelected;
                    });
                  },
                )
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
              RaisedButton(
                color: Layout.secondary(),
                child: Text('Cancelar', style:TextStyle(color: Layout.light())),
                padding: EdgeInsets.only(left: 50, right: 50),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                color: Layout.primary(),
                child: Text('Salvar', style:TextStyle(color: Layout.light())),
                padding: EdgeInsets.only(left: 50, right: 50),
                onPressed: () {
                  if (_formKey.currentState.validate()) {

                    // Instancia model
                    ModelItem itemBo = ModelItem();

                    // Adiciona no banco de dados
                    itemBo.insert({
                      'fk_lista': ItemsPage.pkList,
                      'name': _cName.text,
                      'quantidade': _cQtd.text,
                      'precisao': unity[selectedUnit],
                      'valor': _cValor.text,
                      'checked': this.isSelected,
                      'created': DateTime.now().toString()
                    }).then((saved) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(ItemsPage.tag);
                    });
                  }
                },
              )
            ])
          ]
        ),
      )
    );

    return Layout.getContent(context, content, false);
  }
}
