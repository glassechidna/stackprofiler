$(function() {
    $('#foo').split({
        orientation: 'horizontal',
        limit: 10,
        position: '40%'
    });

    var $filteredFrames = $('#filtered_frames');
    $filteredFrames.tokenfield();

    var $tree = $('#jstree_demo');

    $('#rebase_stack_enabled').change(function(e) {
        var enabled = $(e.target).is(':checked');
        $('#rebase_stack').prop('disabled', !enabled);
    });

    $('#rebase_stack').autocomplete({
        source: "/__stackprofiler/frame_names?run_id=" + $tree.data('runId'),
        minLength: 2
    });

    var getParams = function()
    {
        var params = {
            run_id: $tree.data('runId'),
            filters: {}
        };

        params.filters.filtered_frames = {regexes: $filteredFrames.val().split(', ')};
        params.filters.quick_method_removal = {limit: $('form#options input[name="quick_method_removal"]').val()};

        if ($('#rebase_stack_enabled').is(':checked')) params.filters.rebase_stack = {name: $('#rebase_stack').val() };
        if ($('form#options input[name="invert"]').is(':checked')) params.filters.build_tree = {invert: true};
        if ($('form#options input[name="remove_gems"]').is(':checked')) params.filters.remove_gems = {};
        if ($('form#options input[name="compress_tree"]').is(':checked')) params.filters.compress_tree = {};

        return params;
    };

    var getNodes = function(node, cb) {
        $.post("/__stackprofiler/json", JSON.stringify(getParams()), function(data, status, xhr) {
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
