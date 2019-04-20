#!/bin/sh
"/idea-IC-191.6707.61/jre64/bin/java" -cp "/idea-IC-191.6707.61/plugins/git4idea/lib/git4idea-rt.jar:/idea-IC-191.6707.61/lib/xmlrpc-2.0.1.jar:/idea-IC-191.6707.61/lib/commons-codec-1.10.jar:/idea-IC-191.6707.61/lib/util.jar" org.jetbrains.git4idea.nativessh.GitNativeSshAskPassApp "$@"
