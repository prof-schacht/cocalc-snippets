#!/usr/bin/env coffee
# read the .js files
# for now, we only do this for the physical constants

fs = require('fs')

define = (x) -> x

header = ->
    '''
    # CoCalc Examples Documentation File
    # Copyright: CoCalc Authors, 2018
    # This is derived content from the BSD licensed https://github.com/moble/jupyter_boilerplate/

    # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # THIS FILE IS AUTOGENERATED -- DO NOT EDIT BY HAND #
    # # # # # # # # # # # # # # # # # # # # # # # # # # #

    ---
    language: python
    ''' + '\n'

read_submenu = (entry, cat0, name_prefix, cat_prefix, cat_process) ->
    cat_process ?= (x) -> x
    if name_prefix?
        prefix = "#{name_prefix}"
    else
        prefix = ''
    submenu  = entry['sub-menu']
    cat1     = cat_process(entry['name'])
    output   = []

    if cat1 == 'Example'
        return output

    output.push('---')
    subcat = (x for x in [prefix, cat1] when x?.length > 0).join(' / ')
    output.push("category: ['#{cat0}', '#{subcat}']")
    if cat_prefix?
        # JSON.stringify to sanitize linebreaks
        output.push("setup: #{JSON.stringify(cat_prefix)}")

    for entry in entry['sub-menu']
        # there are weird "---"
        if typeof entry == 'string'
            continue
        # oh yes, sub entries can have subentries ... just skipping them via recursion.
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, cat0, cat1, cat_prefix, cat_process))
        else
            continue if not entry.snippet?  # there are entries where it is only entry["external-link"]
            continue if entry.snippet.join('').trim().length == 0 # ... or some are just empty
            output.push('---')
            #console.log(JSON.stringify(entry))
            output.push(extra) if extra?
            output.push("title: |\n  #{entry.name}")
            #console.log(JSON.stringify(entry))
            code = ("  #{x}" for x in entry.snippet).join('\n')
            output.push("code: |\n#{code}")
    return output

# This is specific to scipy special functions file
read_scipy_special = ->
    special_js   = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/scipy_special.js', 'utf8')
    constants    = eval(special_js)
    output       = []
    cat_prefix   = {'special': 'from scipy import special'}

    for entry in constants['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Scipy', 'Special', cat_prefix, null))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/scipy_special.yaml', content, 'utf8')

# This is specific to matplotlib file
read_matplotlib = ->
    matplotlib_js  = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/matplotlib.js', 'utf8')
    constants      = eval(matplotlib_js)
    output         = []
    cat_prefix     = '''
                     import numpy as np
                     import matplotlib as mpl
                     import matplotlib.pyplot as plt
                     '''

    for entry in constants['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Visualization', 'Matplotlib', cat_prefix, null))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/matplotlib_boilerplate.yaml', content, 'utf8')


# This is specific to the constants file, prints out yaml to stdout
read_constants = ->
    constants_js = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/scipy_constants.js', 'utf8')
    constants    = eval(constants_js)
    output       = []
    cat_prefix   = 'from scipy import constants'

    cat_process = (cat) ->
        return cat.replace('physical constants', '').trim()

    for entry in constants['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Constants', null, cat_prefix, cat_process))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/constants.yaml', content, 'utf8')


# This is specific to the constants file, prints out yaml to stdout
read_python_regex = ->
    pyregex_js   = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/python_regex.js', 'utf8')
    pyregex      = eval(pyregex_js)
    output       = []
    cat_prefix   = 'import re'

    for entry in pyregex['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Regular Expressions', null, cat_prefix))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/python_regex.yaml', content, 'utf8')


read_numpy = ->
    numpy_ufuncs_js       = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/numpy_ufuncs.js', 'utf8')
    numpy_ufuncs          = eval(numpy_ufuncs_js)
    numpy_polynomial_js   = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/numpy_polynomial.js', 'utf8')
    numpy_polynomial      = eval(numpy_polynomial_js)
    # redefine define -- in particular, assumptions and functions is defined now
    orig_define = define
    try
        define = (a, b) ->
            return b(null, numpy_ufuncs, numpy_polynomial)
        numpy_js              = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/numpy.js', 'utf8')
        numpy                 = eval(numpy_js)
    finally
        define = orig_define
    output                = []
    cat_prefix            = '''
                            import numpy as np
                            '''

    cat_process = (x) ->
        if x == 'NumPy'
            return null
        return x

    for entry in numpy['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'NumPy', null, cat_prefix, cat_process))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/numpy_boilerplate.yaml', content, 'utf8')


read_sympy = ->
    assumptions_js     = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/sympy_assumptions.js', 'utf8')
    sympy_assumptions  = eval(assumptions_js)
    functions_js       = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/sympy_functions.js', 'utf8')
    sympy_functions    = eval(functions_js)
    # redefine define -- in particular, assumptions and functions is defined now
    orig_define = define
    try
        define = (a, b) ->
            return b(null, sympy_functions, sympy_assumptions)
        sympy_js           = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/sympy.js', 'utf8')
        sympy              = eval(sympy_js)
    finally
        define = orig_define
    output         = []
    cat_prefix     = '''
                     from sympy import *
                     from sympy.abc import a, s, t, u, v, w, x, y, z
                     k, m, n = symbols("k, m, n", integer=True)
                     f, g, h = symbols("f, g, h", cls=Function)
                     '''

    cat_process = (x) ->
        if x == 'Sympy'
            return null
        return x

    for entry in sympy['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Sympy', null, cat_prefix, cat_process))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/sympy_boilerplate.yaml', content, 'utf8')



main = ->
    read_constants()
    read_scipy_special()
    read_matplotlib()
    read_python_regex()
    # sympy and numpy redefined "define", hence they must come last!
    read_numpy()
    read_sympy()

main()