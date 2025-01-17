import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // Cria os parâmetros da plataforma Android
    const params = PlatformWebViewControllerCreationParams();

    // Cria o controlador WebView com os parâmetros Android
    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Atualize a barra de progresso (opcional)
          },
          onPageStarted: (String url) {
            print('Navegação iniciada: $url');
          },
          onPageFinished: (String url) {
            print('Navegação finalizada: $url');
          },
          onHttpError: (HttpResponseError error) {
            print('Erro HTTP: $error');
          },
          onWebResourceError: (WebResourceError error) {
            print('Erro de recurso Web: $error');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Controle a navegação
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://bus2.info/pr/pontagrossa'));

    // Habilitar debugging no Android
    AndroidWebViewController.enableDebugging(true);
    (controller.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu ônibus em tempo real'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
