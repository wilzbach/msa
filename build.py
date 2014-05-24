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

devFile = "development.html"
buildDir = "build"
buildAMD = "prod_amd.html"
buildNonAMD = "prod_non_amd.html"

externalLibs = ["jquery"]
libName = "biojs"

content = ""
rootDir = path.dirname(path.realpath(__file__))

fnBuildAMD = path.join(rootDir, buildDir, buildAMD);
fnBuildNonAMD = path.join(rootDir, buildDir, buildNonAMD);

def main():

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
    with open(devFile, "r") as file:
        content = file.read()
        html5= fromstring(content)
        body = html5.xpath("//body")[0]
        head = html5.xpath("//head")[0]

        with open(fnBuildAMD, "w") as output:
            root = etree.Element("html")
            headAMD = deepcopy(head)
            root.append(headAMD);
            root.append(replaceCodeElements(deepcopy(body), False))

            headAMD[3] = etree.fromstring("""
            <script>
            requirejs.config({
              baseUrl: '',
            "paths": {
              "jquery": "//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min",
            }
            });
            </script>
           """)

            outStr = html.tostring(root).decode("utf8")
            output.write(outStr)

        with open(fnBuildNonAMD, "w") as output:
            root = etree.Element("html")
            headAMD = deepcopy(head)
            root.append(headAMD);
            root.append(replaceCodeElements(deepcopy(body), True))

            headAMD[3] = etree.fromstring('<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>')
            headAMD[2] = etree.fromstring('<script src="biojs.js"></script>')

            outStr = html.tostring(root).decode("utf8")
            output.write(outStr)



    # copy operations
    print("Copying static files and libs")
    distutils.dir_util.copy_tree(path.join(rootDir, 'css'), path.join(buildDir, 'css'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'dummy'), path.join(buildDir, 'dummy'))
    distutils.dir_util.copy_tree(path.join(rootDir, 'libs'), path.join(buildDir, 'libs'))
    print("Everything is ok. You rock")

def replaceCodeElements(body,removeRequired=False):

    codeElements = body.xpath("//code")
    for ele in codeElements:
        regex = re.compile(r'require\((.*){(.*)}\);',  re.DOTALL | re.MULTILINE)
        groups = regex.search(ele.text).groups()
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

        # dump the header text
        if removeRequired:
            ele.text = bodyGroup
        else:
            headerGroup = json.dumps(headerFilesClean) + ", function(" + ",".join(headerVarsClean) + ")"
            ele.text = "require("+ headerGroup + "{" + bodyGroup + "});";

    return body

if __name__ == "__main__":
    main()
