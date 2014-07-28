// save the current notebook to Galaxy
"using strict";

var save_to_galaxy_extension = (function() {
    saveToGalaxy = function(){
        var kernel = IPython.notebook.kernel;
        var name = IPython.notebook.notebook_name;
        command = 'put("ipython_galaxy_notebook.ipynb")';
        kernel.execute(command);
    };

    IPython.toolbar.add_buttons_group([
        {
            id : 'saveToGalaxy',
            label : 'Save the current notebook in Galaxy',
            icon : 'icon-download-alt',
            callback : saveToGalaxy
        }
    ]);
})();

