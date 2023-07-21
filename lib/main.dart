import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verifique seu CEP',
      theme: ThemeData(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pegue as informações do seu CEP'),
      ),
      body: const Center(
          child: Column(
        children: [
          SearchCep(),
        ],
      )),
    );
  }
}

class Address {
  final String? street;
  final String? city;
  final String? state;

  Address({this.street, this.city, this.state});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
    );
  }
}

class SearchCep extends StatefulWidget {
  const SearchCep({super.key});

  @override
  State<SearchCep> createState() => _SearchCepState();
}

class _SearchCepState extends State<SearchCep> {
  final TextEditingController _cep = TextEditingController();
  String cep = '';

  void _handleButtonClick() {
    setState(() {
      cep = _cep.text;
    });
  }

  Future<Address> getAddressFromCep(String cep) async {
    final url = 'https://brasilapi.com.br/api/cep/v1/$cep';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Address.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
        vertical: 50,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cep,
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                ),
              ),
              TextButton(
                onPressed: _handleButtonClick,
                child: const Text('Procurar'),
              ),
            ],
          ),
          FutureBuilder<Address>(
            future: getAddressFromCep(cep),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final address = snapshot.data;
                if (address != null) {
                  return CepInfo(address: address);
                } else {
                  return const Text('No data available');
                }
              }
            },
          )
        ],
      ),
    );
  }
}

class CepInfo extends StatelessWidget {
  final Address address;
  const CepInfo({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          InfoRow(column1: 'Rua', column2: '${address.street}'),
          InfoRow(column1: 'Cidade', column2: '${address.city}'),
          InfoRow(column1: 'Estado', column2: '${address.state}'),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String column1, column2;
  const InfoRow({super.key, required this.column1, required this.column2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            spreadRadius: .5,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(column1),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: .5),
                ),
              ),
              child: Text(
                column2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
