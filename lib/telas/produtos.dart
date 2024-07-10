import 'dart:convert';

import 'package:aula/componentes/produtocard.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Produtos extends StatefulWidget {
  const Produtos({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProdutosState();
  }
}

const int tamanhoPagina = 4;

class _ProdutosState extends State<Produtos> {
  late dynamic _feedEstatico;
  List<dynamic> _produtos = [];

  int _proximaPagina = 1;
  bool _carregando = false;

  late TextEditingController _controladorFiltragem;
  String _filtro = "";

  @override
  void initState() {
    super.initState();

    _controladorFiltragem = TextEditingController();
    _lerFeedEstatico();
  }

  Future<void> _lerFeedEstatico() async {
    final String conteudoJson =
        await rootBundle.loadString("lib/recursos/json/feed.json");
    _feedEstatico = await json.decode(conteudoJson);

    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _carregando = true;
    });

    var maisProdutos = [];
    if (_filtro.isNotEmpty) {
      _feedEstatico["produtos"].where((item) {
        String nome = item["product"]["name"];

        return nome.toLowerCase().contains(_filtro.toLowerCase());
      }).forEach((item) {
        maisProdutos.add(item);
      });
    } else {
      maisProdutos = _produtos;

      final totalProdutosParaCarregar = _proximaPagina * tamanhoPagina;
      if (_feedEstatico["produtos"].length >= totalProdutosParaCarregar) {
        maisProdutos =
            _feedEstatico["produtos"].sublist(0, totalProdutosParaCarregar);
      }
    }

    setState(() {
      _produtos = maisProdutos;
      _proximaPagina = _proximaPagina + 1;

      _carregando = false;
    });
  }

  Future<void> _atualizarProdutos() async {
    _produtos = [];
    _proximaPagina = 1;

    _carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 60, right: 20),
                    child: TextField(
                      controller: _controladorFiltragem,
                      onSubmitted: (descricao) {
                        _filtro = descricao;

                        _atualizarProdutos();
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search)),
                    ))),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle_outlined))
          ],
        ),
        body: FlatList(
            data: _produtos,
            numColumns: 2,
            loading: _carregando,
            onRefresh: () {
              _filtro = "";
              _controladorFiltragem.clear();

              return _atualizarProdutos();
            },
            onEndReached: () => _carregarProdutos(),
            buildItem: (item, int indice) {
              return SizedBox(height: 400, child: ProdutoCard(produto: item));
            }));
  }
}
