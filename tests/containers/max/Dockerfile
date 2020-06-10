FROM enterprisemediawiki/meza:pre-yum
LABEL MAINTAINER James Montalvo
ENV container=docker

RUN mkdir -p /opt/htdocs \
    && git clone https://gerrit.wikimedia.org/r/p/mediawiki/core.git /opt/htdocs/mediawiki

RUN cd /opt/htdocs/mediawiki/extensions \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/ParserFunctions.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/StringFunctionsEscaped.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/ExternalData.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/LabeledSectionTransclusion.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Cite.git \
    && git clone https://github.com/enterprisemediawiki/ParserFunctionHelper.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/WhoIsWatching.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/CharInsert.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticInternalObjects.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticCompoundQueries.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Arrays.git \
    && git clone https://github.com/enterprisemediawiki/TalkRight.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/AdminLinks.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/DismissableSiteNotice.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/BatchUserRights.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/HeaderTabs.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/WikiEditor.git \
    && git clone https://github.com/jamesmontalvo3/MediaWiki-CopyWatchers.git CopyWatchers \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/SyntaxHighlight_GeSHi.git \
    && git clone https://github.com/enterprisemediawiki/Wiretap.git \
    && git clone https://github.com/jamesmontalvo3/MediaWiki-ApprovedRevs.git ApprovedRevs \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/InputBox.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/ReplaceText.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Interwiki.git \
    && git clone https://github.com/enterprisemediawiki/MasonryMainPage.git \
    && git clone https://github.com/enterprisemediawiki/WatchAnalytics.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Variables.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/YouTube.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/ContributionScores.git \
    && git clone https://github.com/jamesmontalvo3/MediaWiki-PipeEscape.git PipeEscape \
    && git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/UniversalLanguageSelector.git \
    && git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Elastica.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Echo.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Thanks.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/UploadWizard \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/CollapsibleVector \
    && git clone https://github.com/jamesmontalvo3/SimpleMathJax.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/ImageMap \
    && git clone https://github.com/enterprisemediawiki/MezaExt.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/SemanticDrilldown.git \
    && git clone https://github.com/enterprisemediawiki/ImagesLoaded.git \
    && git clone https://github.com/enterprisemediawiki/PageImporter.git \
    && git clone https://github.com/enterprisemediawiki/SemanticMeetingMinutes.git \
    && git clone https://github.com/enterprisemediawiki/HeaderFooter.git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/NumerAlpha.git \
    && git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/DataTransfer.git