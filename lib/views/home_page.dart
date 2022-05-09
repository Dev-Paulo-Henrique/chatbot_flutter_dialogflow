import 'dart:async';

import 'package:chatbot/models/chat_message.dart';
import 'package:chatbot/widgets/chat_message_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageList = <ChatMessage>[];
  final _controllerText = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controllerText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Wendy | Safe Woman'),
      ),
      body: Column(
        children: <Widget>[
          _buildList(),
          const Divider(height: 1.0),
          _buildUserInput(),
        ],
      ),
    );
  }

  // Cria a lista de mensagens (de baixo para cima)
  Widget _buildList() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) =>
            ChatMessageListItem(chatMessage: _messageList[index]),
        itemCount: _messageList.length,
      ),
    );
  }

  // Envia uma mensagem com o padrão a direita
  void _sendMessage({required String text}) {
    _controllerText.clear();
    _addMessage(name: 'Usuário', text: text, type: ChatMessageType.sent);
  }

  // Adiciona uma mensagem na lista de mensagens
  void _addMessage(
      {required String name,
      required String text,
      required ChatMessageType type}) {
    var message = ChatMessage(text: text, name: name, type: type);
    setState(() {
      _messageList.insert(0, message);
    });

    if (type == ChatMessageType.sent) {
      // Envia a mensagem para o chatbot e aguarda sua resposta
      _dialogFlowRequest(query: message.text);
    }
  }

  // Método incompleto ainda
  Future _dialogFlowRequest({required String query}) async {
    // Adiciona uma mensagem temporária na lista
    _addMessage(
        name: 'Wendy', text: 'Digitando...', type: ChatMessageType.received);

    // Faz a autenticação com o serviço, envia a mensagem e recebe uma resposta da Intent
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/credentials.json").build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: "pt-BR");
    AIResponse response = await dialogflow.detectIntent(query);

    // remove a mensagem temporária
    setState(() {
      _messageList.removeAt(0);
    });

    // adiciona a mensagem com a resposta do DialogFlow
    // ignore: avoid_print
    // Timer(const Duration(seconds: 1), () => print('done'));

    _addMessage(
        name: 'Wendy',
        text: response.getMessage() ?? '',
        type: ChatMessageType.received);
  }

  // Campo para escrever a mensagem
  Widget _buildTextField() {
    return new Flexible(
      child: new TextField(
        controller: _controllerText,
        // ignore: prefer_const_constructors
        decoration: new InputDecoration.collapsed(
          hintText: "Enviar mensagem",
        ),
      ),
    );
  }

  // Botão para enviar a mensagem
  Widget _buildSendButton() {
    return new Container(
      margin: const EdgeInsets.only(left: 8.0),
      child: new IconButton(
          icon: new Icon(Icons.send,
              color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            if (_controllerText.text.isNotEmpty) {
              _sendMessage(text: _controllerText.text);
            }
          }),
    );
  }

  // Monta uma linha com o campo de text e o botão de enviao
  Widget _buildUserInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          _buildTextField(),
          _buildSendButton(),
        ],
      ),
    );
  }
}
