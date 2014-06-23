#!/usr/bin/env python3
# encoding: utf-8

# This script transfers the development.html to a either a non AMD or a
# AMD file with just the biojs.library as one compiled file

import re
from lxml.html import parse,fromstring
from lxml import etree, html
from os import path
import os
import distutils.core
import json
import sys
from copy import deepcopy
import subprocess
import shutil
import argparse

devFiles = ["msa.html"]
buildDir = "build"
externalLibs = ["jquery"]
libName = "biojs"

content = ""
rootDir = path.dirname(path.realpath(__file__))
buildDir = path.join(rootDir,buildDir)

parser = argparse.ArgumentParser(description='Build script for BioJS MSA')
parser.add_argument("-s","--skipunittests", action="store_false", dest="executeUnitTests",
        default=True, help="Skips the unit tests")
args = parser.parse_args()

def main():

    print("Cleaning build dir: "+ str(buildDir))
    shutil.rmtree(buildDir, True)

    if which("grunt") and args.executeUnitTests:
        print("Executing unit tests and linting")
        testProcess = subprocess.Popen(["grunt", "--gruntfile", \
                path.join(rootDir, "Gruntfile.js"), "build"], stdout=subprocess.PIPE)
        out, err = testProcess.communicate()
        out = out.decode("utf8")
        sys.stdout.buffer.write(out.encode("utf8"))
        if "Aborted" in out:
            sys.exit("unit test failed")

        # whether to show version info
        showVersions()
    else:
        print("Warning: you have no grunt installed.")


    if not path.exists(buildDir):
        os.makedirs(buildDir)

    print("Compiling to biojs.js")
    # check for node
    if which("node"):
        # call requires via node and compile the lib
        buildProcess = subprocess.Popen(["node", path.join(rootDir,"js/libs/r.js"),  "-o", \
                path.join(rootDir, "config/build.js")], stdout=subprocess.PIPE)
    elif which("java"):
        buildProcess = subprocess.Popen(["java", "-classpath", path.join(rootDir, "jars/rhino.jar") + ":"+ \
                path.join(rootDir, "jars/compiler.jar"), "org.mozilla.javascript.tools.shell.Main", \
                path.join(rootDir, "js/libs/r.js"), "-o", path.join(rootDir, "build.js")], stdout=subprocess.PIPE)
    else:
        print("You have neither node nor java installed. Can't call requirejs compiler")
        sys.exit("r.js optimizer failed")

    if buildProcess:
        out, err = buildProcess.communicate()
        out = out.decode("utf8")
        print(out)
        if "error" in out:
            sys.exit()

    print("Starting to build documentation")

    for devFile in devFiles:
        buildDocumentation(path.join(rootDir, devFile))

    # compile all scss
    cssFolder = path.join(rootDir, "css")
    cssBuildFolder = path.join(buildDir, "css")
    os.mkdir(cssBuildFolder)

    if not which("scss"):
        print("no scss compiler installer");
    else:
        subprocess.call(["scss","-v"])

        for file in os.listdir(cssFolder):
            if file.endswith(".scss") and not file[0] == "_":
                inFile = path.join(cssFolder, file)
                outFile = path.join(cssBuildFolder, file[:-5]+".css")
                print("SCSS: %s -> %s" %(inFile, outFile))
                p = subprocess.Popen(["scss",inFile,outFile],stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stdout, stderr = p.communicate()
                if stdout:
                    print(stdout)
                if stderr:
                    print("Error %s" % stderr)

    # copy operations
    print("Copying static files and libs")
    distutils.dir_util.copy_tree(path.join(rootDir, 'dummy'), path.join(buildDir, 'dummy'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'libs'), path.join(buildDir, 'libs'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'doc-css'), path.join(buildDir, 'doc-css'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'doc-js'), path.join(buildDir, 'doc-js'))
    print("\nEverything is ok. You rock!")

def showVersions():
    print("Installed lib version")
    subprocess.call(["npm", "list", "codo"], cwd=rootDir)


def buildDocumentation(devFile):

    devFileName = path.splitext(path.basename(devFile))[0]

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
              "jquery": "//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min",
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
        if not removeRequired :
            print("snippet %s was sucessfully read." % url)

        regex = re.compile(r'require\((.*?){(.*)}\);',  re.DOTALL | re.MULTILINE)
        groups = regex.search(text).groups()
        headerGroup = groups[0]
        bodyGroup = groups[1]

        if "io_" in url and removeRequired:
            print(bodyGroup)
            print(len(groups))

        # recognize internal scripts
        regex = re.compile(r'(\[.*\])', re.MULTILINE  | re.DOTALL)
        headerFiles = regex.search(headerGroup).groups()[0]
        headerFiles = json.loads(headerFiles)

        # recognize vars
        regex = re.compile(r'function[ ]*\((.*)\)', re.MULTILINE  | re.DOTALL)
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

                if className[-5:] == ".main" :
                    className = className[:-5]

                # search for all oc
                # variable needs whitespace on the left and either '(',
                # '.', ';' or whitespace on the right
                bodyGroup = re.sub(r' ' + hVar + r'([. ;(])', ' ' + libName + '.' + className + r'\1' , bodyGroup)

        # always add biojs
        headerVarsClean.append(libName)
        headerFilesClean.append(libName)

        # remove it
        row.remove(ele)


        # dump the header text
        if removeRequired:
            sourceText = bodyGroup
            # remove one indent level
            newLines = []
            lines = sourceText.split("\n")
            # search for the first non-empty line
            for line in lines[1:]:
                if len(line.strip(" ")) > 0:
                    whitespacesInLine = len(line) -len(line.lstrip(" "))
                    break
            # remove in all lines the found indention
            for line in lines[1:]:
                newLines.append(line[whitespacesInLine:])
            sourceText= "\n".join(newLines)
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

def which(program):
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None
if __name__ == "__main__":
    main()
