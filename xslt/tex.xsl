<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    <xsl:output encoding="UTF-8" media-type="text" omit-xml-declaration="true" indent="no"/>
    
<xsl:template match="/">
%\documentclass[11pt,headings=small,a4paper]{scrartcl}
\documentclass{article}
\usepackage{fontspec}        % For font management
\usepackage{polyglossia}     % For multilingual support
%\usepackage[document]{ragged2e} % old, linksbündig für alles
\usepackage[headings]{ragged2e}


% Set main language
\setmainlanguage{german}
% Set other language
\setotherlanguage{greek}

\newfontfamily\greekfont{FreeSerif}

\usepackage{titlesec}
\titleformat{\section}
  {\normalfont\sffamily\large}
  {\thesection}{1em}{}

% TOC setup
\usepackage{tocloft}
\renewcommand\cftsecfont{\fontsize{10}{10}\selectfont}
\renewcommand\cftsecpagefont{\fontsize{9}{10}\selectfont}
\setlength\cftbeforesecskip{0pt}

% Footnote setup
\usepackage{bigfoot} %improved fn management
\usepackage[hang, norule]{footmisc} %hanging footnotes without rule separator
% smaller Footnotemark
\deffootnotemark{\raisebox{3pt}{\scriptsize\thefootnotemark}}
% set low penalties for split footnotes
\footnotewidowpenalty=10
\footnoteclubpenalty=10
\finalfootnotewidowpenalty=10
\interfootnotelinepenalty=0

\usepackage{imakeidx}
\makeatletter
% we don't want a page break before the first subitem
% https://tex.stackexchange.com/questions/130169/how-can-i-prevent-a-column-break-before-the-first-sub-entry-in-the-index
% set index indent to 6pt 
\newif\iffirst@subitem
\def\@idxitem{%
\pagebreak[2]\par\hangindent6\p@ % original
\first@subitemtrue   % added
}
\def\subitem{%
\par\hangindent12\p@~–\,
    \iffirst@subitem
    \nobreak
    \first@subitemfalse
    \fi
    \hspace*{2\p@}}
    \makeatother


\setlength\parindent{2.6em}

\title{Tillich-Briefe}
\author{Tillich Briefe Team}
\date{Herbst 2024}
\makeindex[name=person,title=Personenindex,columnsep=14pt,columns=3]
\makeindex[name=place,title=Ortsindex,columnsep=14pt,columns=3]
\makeindex[name=work,title=Werkindex,columnsep=14pt,columns=3]
\makeindex[name=letter,title=Briefindex,columnsep=14pt,columns=3]

\usepackage[hidelinks]{hyperref}

\begin{document}
\maketitle
\clearpage
\tableofcontents
\clearpage
<xsl:for-each select="collection('../data/editions/?select=*.xml')/tei:TEI">
    <xsl:sort select="./@xml:id"></xsl:sort>
    <xsl:variable name="docId">
        <xsl:value-of select="replace(./@xml:id, '.xml', '')"/>
    </xsl:variable>
    <xsl:variable name="title">
        <xsl:value-of select=".//tei:titleStmt/tei:title[1]/text()"/>
    </xsl:variable>
\section*{<xsl:text>(</xsl:text><xsl:value-of select="$docId"/><xsl:text>) </xsl:text><xsl:value-of select="$title"/>}
    \addcontentsline{toc}{subsection}{<xsl:value-of select="$title"/>}
\begin{FlushRight}
<xsl:apply-templates select=".//tei:dateline"/>
\end{FlushRight}
<xsl:for-each select=".//tei:body//tei:div">
\begin{FlushLeft}
<xsl:value-of select=".//tei:opener/tei:salute//text()"/>
\end{FlushLeft}

<xsl:for-each select=".//tei:p[not(parent::tei:postscript)]">
    \par
    <xsl:if test="position()=1">\noindent </xsl:if>
    <xsl:apply-templates/>
    \par 
</xsl:for-each>

\bigskip
<xsl:apply-templates select=".//tei:closer"/>

</xsl:for-each>
</xsl:for-each>

\newpage
\back\small
\printindex[person]
\printindex[place]
%\printindex[letter]
\end{document}
        
</xsl:template>
    
    <xsl:template match="tei:dateline">
<xsl:value-of select="replace(
    normalize-space(string-join(.//text())),
    ' , ', ', '
    )"/>
</xsl:template>
    
<xsl:template match="tei:del">\sout{<xsl:value-of select="."/>}</xsl:template>
<xsl:template match="tei:note">
\footnote{<xsl:apply-templates/>}
</xsl:template>
<xsl:template match="tei:unclear">
<xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
</xsl:template>
    <xsl:template match="tei:foreign[@xml:lang='grc']"><xsl:text>\begin{greek}</xsl:text><xsl:apply-templates/><xsl:text>\end{greek}</xsl:text></xsl:template>
    <xsl:template match="tei:salute">
        <xsl:apply-templates/>\par\smallskip
        
    </xsl:template>
    <xsl:template match="tei:rs">
        <xsl:variable name="rstype" select="@type"/>
        <xsl:variable name="rsid" select="substring-after(@ref, '#')"/>
        <xsl:variable name="ent" select="root()//tei:back//*[@xml:id=$rsid]"/>
        <xsl:variable name="idxlabel" select="$ent/*[contains(name(), 'Name')][1]"/>
        <xsl:value-of select="'\index['||$rstype||']{'||$idxlabel||'} '"/>
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
