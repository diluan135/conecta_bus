import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as customTabs;

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  Future<void> _launchURL(BuildContext context, String url) async {
    final theme = Theme.of(context);
    try {
      await customTabs.launchUrl(
        Uri.parse(url),
        customTabsOptions: customTabs.CustomTabsOptions(
          colorSchemes: customTabs.CustomTabsColorSchemes.defaults(
            toolbarColor: theme.primaryColor,
          ),
          shareState: customTabs.CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: customTabs.CustomTabsCloseButton(
            icon: customTabs.CustomTabsCloseButtonIcons.back,
          ),
        ),
        safariVCOptions: customTabs.SafariViewControllerOptions(
          preferredBarTintColor: theme.primaryColor,
          preferredControlTintColor: theme.colorScheme.onPrimary,
          barCollapsingEnabled: true,
          dismissButtonStyle: customTabs.SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  _launchURL(
                      context, 'https://transportes.pontagrossa.pr.gov.br/');
                },
                child: const Image(
                  image: AssetImage("images/pg_bandeira.png"),
                  width: 124,
                  height: 124,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _launchURL(
                      context, 'https://valedostrilhos.pontagrossa.pr.gov.br');
                },
                child: const Image(
                  image: AssetImage("images/vale_dos_trilhos.png"),
                  width: 124,
                  height: 124,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
