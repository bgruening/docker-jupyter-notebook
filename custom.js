// leave at least 2 line with only a star on it below, or doc generation fails
/**
 *
 *
 * Placeholder for custom user javascript
 * mainly to be overridden in profile/static/custom/custom.js
 * This will always be an empty file in IPython
 *
 * User could add any javascript in the `profile/static/custom/custom.js` file
 * (and should create it if it does not exist).
 * It will be executed by the ipython notebook at load time.
 *
 * Same thing with `profile/static/custom/custom.css` to inject custom css into the notebook.
 *
 * Example :
 *
 * Create a custom button in toolbar that execute `%qtconsole` in kernel
 * and hence open a qtconsole attached to the same kernel as the current notebook
 *
 *    $([IPython.events]).on('app_initialized.NotebookApp', function(){
 *        IPython.toolbar.add_buttons_group([
 *            {
 *                 'label'   : 'run qtconsole',
 *                 'icon'    : 'icon-terminal', // select your icon from http://fortawesome.github.io/Font-Awesome/icons
 *                 'callback': function () {
 *                     IPython.notebook.kernel.execute('%qtconsole')
 *                 }
 *            }
 *            // add more button here if needed.
 *            ]);
 *    });
 *
 * Example :
 *
 *  Use `jQuery.getScript(url [, success(script, textStatus, jqXHR)] );`
 *  to load custom script into the notebook.
 *
 *    // to load the metadata ui extension example.
 *    $.getScript('/static/notebook/js/celltoolbarpresets/example.js');
 *    // or
 *    // to load the metadata ui extension to control slideshow mode / reveal js for nbconvert
 *    $.getScript('/static/notebook/js/celltoolbarpresets/slideshow.js');
 *
 *
 * @module IPython
 * @namespace IPython
 * @class customjs
 * @static
 */


    $([Jupyter.events]).on("notebook_loaded.Notebook", function () {
      Jupyter.notebook.set_autosave_interval(5000);
    });

    IPython.keyboard_manager.command_shortcuts.add_shortcut('ctrl-k', function (event) {
          IPython.notebook.move_cell_up();
          return false;
    });

    IPython.keyboard_manager.command_shortcuts.add_shortcut('ctrl-j', function (event) {
          IPython.notebook.move_cell_down();
          return false;
    });

    // Create callback
    var saveToGalaxy = function(){
        var kernel = IPython.notebook.kernel;
        var name = IPython.notebook.notebook_name;
        // save notebook before sending it to the Galaxy-History
        IPython.notebook.save_notebook();
        IPython.notebook.save_checkpoint();
        command = 'put("ipython_galaxy_notebook.ipynb", "ipynb")';
        kernel.execute(command);
    };
    // Register button group
    Jupyter.toolbar.add_buttons_group([
        {
            id : 'saveToGalaxy',
            label : 'Save the current notebook in Galaxy',
            icon : 'fa-download fa',
            callback : saveToGalaxy
         },
    ]);

