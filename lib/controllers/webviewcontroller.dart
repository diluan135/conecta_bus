import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// Inicializando o controlador com base na plataforma
WebViewController createWebViewController() {
  late final PlatformWebViewControllerCreationParams params;

  // Verifica se a plataforma é iOS/macOS
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
  } else {
    // Para Android e outras plataformas
    params = const PlatformWebViewControllerCreationParams();
  }

  // Criação do controlador com parâmetros específicos da plataforma
  final WebViewController controller =
      WebViewController.fromPlatformCreationParams(params);

  // Configurações específicas para Android
  if (controller.platform is AndroidWebViewController) {
    AndroidWebViewController.enableDebugging(true);
    (controller.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }

  // Configurações gerais para o WebViewController
  controller
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Aqui você pode atualizar a barra de progresso
          print('Progresso: $progress%');
        },
        onPageStarted: (String url) {
          print('Página começou a carregar: $url');
        },
        onPageFinished: (String url) {
          print('Página carregada: $url');
        },
        onHttpError: (HttpResponseError error) {
          print('Erro HTTP: ${error}');
        },
        onWebResourceError: (WebResourceError error) {
          print('Erro no recurso web: ${error.description}');
        },
        onNavigationRequest: (NavigationRequest request) {
          // Impede a navegação para o YouTube
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://flutter.dev'));

  return controller;
}
