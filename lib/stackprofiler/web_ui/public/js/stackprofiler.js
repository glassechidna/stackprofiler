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

    $.getJSON('/__stackprofiler/gem_breakdown?run_id=' + $tree.data('runId'), function(data, status, xhr) {
        var objs = _(data).map(function(count, gem) {
            return {label: gem, value: count};
        }).sortBy('value').reverse().value();

        var summer = function(memo, item) {
            return memo + item.value;
        };

        var sum = _.reduce(objs, summer, 0);

        var threshold = 0.1;
        var thresholder = function(item) {
            return item.value/sum > threshold;
        };

        var below_threshold = _.reject(objs, thresholder);
        var other_count = _.reduce(below_threshold, summer, 0);

        var graph_data = _.filter(objs, thresholder);
        graph_data.push({label: '(other)', value: other_count});

        var colors = d3.scale.category10().range();

        var rows = _(objs).zip(colors).first(objs.length).map(function(item) {
            var gem = item[0];
            var percent = (gem.value / sum * 100).toFixed(1);
            var has_color = gem.value/sum > threshold;
            var style = has_color ? 'background-color: ' + item[1] + ';' : '';
            return $('<tr><td><div class="color-box" style="' + style + '"></div>' + gem.label + '</td><td>' + gem.value + '</td><td>' + percent + '%</td></tr>');
        }).value();
        
        $('#gem-pie').epoch({
            type: 'pie',
            data: graph_data
        });

        $('#gem-table').append(rows);
    });
});
