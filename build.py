#!/usr/bin/env python3
# encoding: utf-8

# This script transfers the development.html to a either a non AMD or a
# AMD file with just the biojs.library as one compiled file

import re
from lxml.html import parse,fromstring
from lxml import etree, html
from os import path
import distutils.core
import json
import sys
from copy import deepcopy
import subprocess
import shutil

devFiles = ["msa.html", "input.html"]
buildDir = "build"
externalLibs = ["jquery"]
libName = "biojs"

content = ""
rootDir = path.dirname(path.realpath(__file__))

def main():

    print("Cleaning build dir")
    shutil.rmtree(buildDir)

    print("Compiling to biojs.js")
    # check for node
    if shutil.which("node"):
        # call requires via node and compile the lib
        subprocess.call(["node", path.join(rootDir,"js/libs/r.js"),  "-o", \
                path.join(rootDir, "build.js")])
    elif shutil.which("java"):
        subprocess.call(["java", "-classpath", path.join(rootDir, "jars/rhino.jar") + ":"+ \
                path.join(rootDir, "jars/compiler.jar"), "org.mozilla.javascript.tools.shell.Main", \
                path.join(rootDir, "js/libs/r.js"), "-o", path.join(rootDir, "build.js")])
    else:
        print("You have neither node nor java installed. Can't call requirejs compiler")
        sys.exit()

    print("Starting to build documentation")

    for devFile in devFiles:
        buildDocumentation(devFile)

    # copy operations
    print("Copying static files and libs")
    distutils.dir_util.copy_tree(path.join(rootDir, 'css'), path.join(buildDir, 'css'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'dummy'), path.join(buildDir, 'dummy'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'libs'), path.join(buildDir, 'libs'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'doc-js'), path.join(buildDir, 'doc-js'))
    print("\nEverything is ok. You rock!")

def buildDocumentation(devFile):

    devFileName = path.splitext(devFile)[0]

    # html files
    fnBuildAMD= path.join(buildDir,devFileName + "_amd.html")
    fnBuildNonAMD= path.join(buildDir,devFileName + "_non_amd.html")

    # snippet file names
    snipFileAMD = devFileName + "_amd_snip.js"
    snipFileNonAMD = devFileName + "_non_amd_snip.js"

    # snippet files
    fSnipFileAMD= path.join(buildDir,snipFileAMD)
    fSnipFileNonAMD= path.join(buildDir,snipFileNonAMD)


    with open(devFile, "r") as file:
        content = file.read()
        html5= fromstring(content)


        with open(fnBuildAMD, "w") as output:
            root = etree.Element("html")

            amdHtml = deepcopy(html5)
            body = amdHtml.xpath("//body")[0]
            head = amdHtml.xpath("//head")[0]

            root.append(head);
            root.append(replaceCodeElements(body, fSnipFileAMD,False))

            head[4] = etree.fromstring("""
            <script>
            requirejs.config({
              baseUrl: '',
            "paths": {
              "jquery": "//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min",
            }
            });
            </script>
           """)
            head.append(etree.fromstring('<script src="'+snipFileAMD +'"></script>'))

            # remove highlight script
            ele = root.xpath('//script[@id="loadBoxes"]')[0]
            del ele.attrib["id"]
            del ele.attrib["src"]
            ele.text = """ require(['jquery'], function($){
            $(document).ready(function() {
                      $('pre code').each(function(i, e) {hljs.highlightBlock(e)});
                        });
                        });"""

            outStr = html.tostring(root).decode("utf8")
            output.write(outStr)

        with open(fnBuildNonAMD, "w") as output:
            root = etree.Element("html")

            amdHtml = deepcopy(html5)
            body = html5.xpath("//body")[0]
            head = html5.xpath("//head")[0]

            root.append(head);
            root.append(replaceCodeElements(body,fSnipFileNonAMD, True))

            head[4] = etree.fromstring('<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>')
            head[3] = etree.fromstring('<script src="biojs.js"></script>')
            head.append(etree.fromstring('<script src="'+snipFileNonAMD +'"></script>'))

            # remove highlight script
            ele = root.xpath('//script[@id="loadBoxes"]')[0]
            del ele.attrib["id"]
            del ele.attrib["src"]
            ele.text = """$(document).ready(function() {
                      $('pre code').each(function(i, e) {hljs.highlightBlock(e)});
                        });"""

            outStr = html.tostring(root).decode("utf8")
            output.write(outStr)

def replaceCodeElements(body,oFile,removeRequired=False):

    rows = body.xpath('//*[@class="row"]')
    snips = []

    for row in rows:

        ele = row.xpath("//script")[0]

        # read the snippet
        url = ele.attrib["src"]

        with open(path.join(rootDir, url), "r") as cfile:
            text = cfile.read()

        # show log only once
        if removeRequired :
            print("snippet %s was sucessfully read." % url)

        regex = re.compile(r'require\((.*){(.*)}\);',  re.DOTALL | re.MULTILINE)
        groups = regex.search(text).groups()
        headerGroup = groups[0]
        bodyGroup = groups[1]

        # recognize internal scripts
        regex = re.compile(r'(\[.*\])')
        headerFiles = regex.search(headerGroup).groups()[0]
        headerFiles = json.loads(headerFiles)

        # recoginze vars
        regex = re.compile(r'function[ ]*\((.*)\)')
        headerVars = regex.search(headerGroup).groups()[0].split(",")
        headerVars = [x.strip(' ') for x in headerVars]

        if len(headerVars) != len(headerFiles):
            print("function arguments must have the same length as the header files")
            sys.exit()

        # only include external libs
        headerVarsClean = []
        headerFilesClean = []

        for index,hScript in enumerate(headerFiles):
            hVar = headerVars[index]

            # whether the class comes from biojs
            if hScript in externalLibs:
                headerFilesClean.append(hScript)
                headerVarsClean.append(hVar)
            else:
                className = hScript.replace("/", ".")
                className = className.replace("cs!", "")

                # search for all occ
                bodyGroup = re.sub(r' ' + hVar + r'([ ;(])', ' ' + libName + '.' + className + r'\1' , bodyGroup)

        # always add biojs
        headerVarsClean.append(libName)
        headerFilesClean.append(libName)

        # remove it
        row.remove(ele)


        # dump the header text
        if removeRequired:
            sourceText = bodyGroup
        else:
            headerGroup = json.dumps(headerFilesClean) + ", function(" + ",".join(headerVarsClean) + ")"
            sourceText = "require("+ headerGroup + "{" + bodyGroup + "});"

        sourceText =sourceText.strip(' \t\n\r')
        snips.append(sourceText);

        # dump it as HTML
        sourceBox = row.xpath('.//*[@class="source-code"]')[0]
        sourcePre = etree.Element("pre")
        sourcePre.attrib["class"] = 'hljs-js'
        sourceCodeEl = etree.Element("code")
        sourceCodeEl.text = sourceText

        sourcePre.append(sourceCodeEl)
        sourceBox.append(sourcePre)


    with open(oFile,"w") as snipFile:
        snipFile.write("window.onload = function(){\n")
        for snip in snips:
                snipFile.write(snip)
                snipFile.write("\n")
        snipFile.write("}")

    return body

if __name__ == "__main__":
    main()
