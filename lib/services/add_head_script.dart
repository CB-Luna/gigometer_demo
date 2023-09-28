// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void addHeadScript(script) {
  var head = querySelector('head');
  if (head != null) {
    var currentHead = head.innerHtml;
    head.setInnerHtml('$currentHead $script',
        validator: NodeValidatorBuilder.common()
          ..allowElement('SCRIPT', attributes: [
            'src',
            'type',
            'async',
            'defer',
            'crossorigin',
            'integrity',
            'nonce',
            'language',
            'nomodule',
            'referrerpolicy',
            'charset',
            'srcdoc',
            'id',
            'class',
            'style',
            'title',
            'hidden',
            'tabindex',
            'accesskey',
            'dir',
            'data-main',
            'data-requiremodule',
            'data-requirecontext',
            'data-requireplugin',
            'data-requiremodules',
            'data-requireurl',
          ])
          ..allowElement('META', attributes: [
            'name',
            'http-equiv',
            'content',
            'charset',
            'flt-viewport',
          ])
          ..allowElement('TITLE')
          ..allowElement('BASE', attributes: ['href', 'target'])
          ..allowElement('LINK', attributes: [
            'rel',
            'href',
            'type',
            'hreflang',
            'media',
            'integrity',
            'crossorigin',
            'as',
            'imagesrcset',
            'imagesizes',
            'title',
            'charset',
          ]));
  }
}
