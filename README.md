# i4neo Beamertheme

**neo** ist ein einfacher und moderner Ersatz für das (optisch) bereits in die Jahre gekommene [i4 Latex-Beamertheme](https://gitlab.cs.fau.de/i4/tex/i4beamer).
Ziel war eine gemeinsame Vorlage sowohl für Vorlesungs- und Übungsfolien als auch für externe (Konferenz-)Präsentationen, ohne unnötige oder redundante Störelemente.

Die Vorlage ist eine Modifikation von [Matthias Vogelgesang](http://bloerg.net/2014/09/20/a-modern-beamer-theme.html)s [Metropolis](https://github.com/matze/mtheme) (auch als [CTAN-Paket](http://ctan.org/pkg/beamertheme-metropolis) verfügbar).


## Verwendung

Die `STY`-Paketdateien können mittels

    make sty

erstellt werden und wie übliche Beamerthemes verwendet werden, jedoch beinhaltet das Makefile auch genug Magie um die komplette Erstellung zu übernehmen.
Ebenfalls muss das Projekt nicht in dem Themeordner entwickelt werden, sondern kann als Unterordner im Präsentationsordner mit dem Befehl

    git clone https://gitlab.cs.fau.de/i4/tex/i4neo.git theme

geklont werden. Falls die Präsentation in GIT verwaltet wird, empfiehlt es sich als Untermodul eingebettet

    git submodule add git@gitlab.cs.fau.de:i4/tex/i4neo.git theme

Eine Makefile im Präsentationsordner kann dazu die entsprechende Theme-Makefile einbinden (und optional weitere Targets bereitstellen):

    include theme/Makefile


### Minimales Beispiel in LaTeX

```latex
\documentclass{beamer}
\usetheme{neo}
\title{Ein kleines Beispiel}
\date{\today}
\author{Wolfgang Händler}
\institute{Friedrich-Alexander-Universität Erlangen-Nürnberg}
\begin{document}
  \maketitle
  \section{Erster Abschnitt}
  \begin{frame}{Erste Folie}
    Hallo Welt!
  \end{frame}
\end{document}
```

Weiterführende Informationen über die Verwendung der Vorlage sind in der [Dokumentation](doc/neotheme.pdf) zu finden.

Ein ausführliches Beispiel wird in [i4neo Demo](https://gitlab.cs.fau.de/i4/tex/i4neo-demo) gezeigt.


### Minimales Beispiel in Markdown

Analog zum vorherigen Beispiel, hier wird jedoch die LaTeX aus Markdown mittels [Pandoc](https://pandoc.org/) generiert

```markdown
---
title: Ein kleines Beispiel
date: \today
author: Wolfgang Händler
institute: Friedrich-Alexander-Universität Erlangen-Nürnberg
---

# Erster Abschnitt

## Erste Folie

Hallo Welt
```


## Hinweise

  * Die Verwendung von [XeTeX](https://de.wikipedia.org/wiki/XeTeX) wird wegen den besseren Schriftsatz der eingebetteten OpenType-[Fira-Schriftfamilie](http://mozilla.github.io/Fira/) empfohlen.


## Lizenz

Die Vorlage selbst ist unter der [Creative Commons Attribution-ShareAlike
4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/) lizenziert. Es gelten folgenden Bedingungen:

 * **Namensnennung:** Sie müssen angemessene Urheber- und Rechteangaben machen, einen Link zur Lizenz beifügen und angeben, ob Änderungen vorgenommen wurden. Diese Angaben dürfen in jeder angemessenen Art und Weise gemacht werden, allerdings nicht so, dass der Eindruck entsteht, der Lizenzgeber unterstütze gerade Sie oder Ihre Nutzung besonders.
 * **Weitergabe unter gleichen Bedingungen:** Wenn Sie die Vorlage verändern, dürfen Sie Ihre Beiträge nur unter derselben Lizenz wie das Original verbreiten. Dies betrifft jedoch **nicht** die Präsentationen, die unter Verwendung dieser Vorlage erstellt wurden
 * **Keine weiteren Einschränkungen:** Sie dürfen keine zusätzlichen Klauseln oder technische Verfahren einsetzen, die anderen rechtlich irgendetwas untersagen, was die Lizenz erlaubt.
