$(function() {
    $('#foo').split({
        orientation: 'horizontal',
        limit: 10,
        position: '40%'
    });

    var $tree = $('#jstree_demo');

    var getParams = function()
    {
        var params = {filters: {}};

        if ($('form#options input[name="invert"]').is(':checked')) params.filters.build_tree = {invert: true};
        if ($('form#options input[name="stackprofiler_elision"]').is(':checked')) params.filters.stackprofiler_elision = {};
        if ($('form#options input[name="remove_gems"]').is(':checked')) params.filters.remove_gems = {};
        if ($('form#options input[name="quick_method_elision"]').is(':checked')) params.filters.quick_method_elision = {};
        if ($('form#options input[name="compress_tree"]').is(':checked')) params.filters.compress_tree = {};

        return params;
    };

    var getNodes = function(node, cb) {
        $.post("/__stackprofiler/json?run_id=" + $tree.data('runId'), JSON.stringify(getParams()), function(data, status, xhr) {
            cb.call(this, data);
        });
    };

    $tree.jstree({
        core: {
            data: getNodes
        }
    });

    $tree.on("changed.jstree", function (e, data) {
        if (!data.node) return;

        var addrs = data.node.data.addrs;
        var url = "/__stackprofiler/code/" + addrs[0] + "?run_id=" + $tree.data('runId');
        $("#source-display").load(url);
    });

    $('button#save-options').click(function() {
        $tree.jstree().refresh();
    });
});
