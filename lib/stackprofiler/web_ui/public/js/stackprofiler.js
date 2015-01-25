var Stackprofiler = (function(me) {
    me.init = function() {
        $('#foo').split({
            orientation: 'horizontal',
            limit: 10,
            position: '40%'
        });

        me.tree.init();
        me.editor.init();

        $.getJSON('/gem_breakdown?run_id=' + me.tree.$tree.data('runId'), me.populateGemBreakdown);

        $('#filtered_frames').tokenfield();

        $('#rebase_stack_enabled').change(function(e) {
            var enabled = $(e.target).is(':checked');
            $('#rebase_stack').prop('disabled', !enabled);
        });

        $('#rebase_stack').autocomplete({
            source: "/frame_names?run_id=" + me.tree.$tree.data('runId'),
            minLength: 2
        });

        $('button#save-options').click(function() {
            me.tree.$tree.jstree().refresh();
        });
    };

    me.populateGemBreakdown = function(data, status, xhr) {
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

    };

    return me;
}(Stackprofiler || {}));

Stackprofiler.editor = (function() {
    var me = {};
    
    me.markerIds = [];
    me.gutterIds = [];

    var Range = ace.require("ace/range").Range;

    me.init = function() {
        var editor = ace.edit("editor");
        editor.setReadOnly(true);
        editor.setTheme("ace/theme/xcode");
        editor.getSession().setMode("ace/mode/ruby");
        me.editor = editor;
    };

    me.updateEditor = function(data) {
        _.map(me.markerIds, function(markerId) {
            me.editor.session.removeMarker(markerId);
        });
        me.markerIds = [];
        _.map(me.gutterIds, function(gutter) {
            me.editor.session.removeGutterDecoration(gutter[0], gutter[1]);
        });
        me.gutterIds = [];

        me.editor.setValue(data.lines, -1);
        var samples_sum = _.reduce(data.samples, function(sum, sample, line) {
            return sum + sample[0];
        }, 0);
        _.forIn(data.samples, function(samples, line_str) {
            var line = parseInt(line_str, 10);
            var pc = Math.round(samples[0] / samples_sum * 10) * 10;
            var klass = "ace-red-" + pc;
            me.markerIds.push(me.editor.session.addMarker(new Range(line, 0, line, 200), klass, "fullLine"));

            var gutter_klass = "profile-line-" + line;
            var gutter_content = samples.join("/");
            $('<style type="text/css"> .'+ gutter_klass + ':before { content: "' + gutter_content + '"; padding-right: 20px; } </style>').appendTo('head');
            me.editor.session.addGutterDecoration(line, gutter_klass);
            me.gutterIds.push([line, gutter_klass]);
        });

    };


    return me;
}());

Stackprofiler.tree = (function() {
    var me = {};

    me.init = function() {
        me.$tree = $('#jstree_demo');
        me.$tree.jstree({
            core: {
                data: me.getNodes
            }
        });

        me.$tree.on("changed.jstree", me.onChangedTree);
    };

    me.onChangedTree = function(e, data) {
        if (!data.node) return;

        var addrs = data.node.data.addrs;
        var url = "/code/" + addrs[0] + "?run_id=" + me.$tree.data('runId');
        $.getJSON(url).success(Stackprofiler.editor.updateEditor);
    };

    me.getNodes = function(node, cb) {
        $.post("/json", JSON.stringify(me.getParams()), function(data, status, xhr) {
            cb.call(this, data);
        });
    };

    me.getParams = function()
    {
        var params = {
            run_id: me.$tree.data('runId'),
            filters: {}
        };

        params.filters.filtered_frames = {regexes: $('#filtered_frames').val().split(', ')};
        params.filters.quick_method_removal = {limit: $('form#options input[name="quick_method_removal"]').val()};

        if ($('#rebase_stack_enabled').is(':checked')) params.filters.rebase_stack = {name: $('#rebase_stack').val() };
        if ($('form#options input[name="invert"]').is(':checked')) params.filters.build_tree = {invert: true};
        if ($('form#options input[name="remove_gems"]').is(':checked')) params.filters.remove_gems = {};
        if ($('form#options input[name="compress_tree"]').is(':checked')) params.filters.compress_tree = {};

        return params;
    };

    return me;
}());

$(function() {
    Stackprofiler.init();
});
