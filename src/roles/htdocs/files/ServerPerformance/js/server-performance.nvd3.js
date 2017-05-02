$(document).ready(function(){

    /**
        {
            dailyHits : [
                {
                    key : "Series 1",
                    values : [
                        { x: timestamp, y: value },
                        { x: timestamp, y: value },
                        { x: timestamp, y: value },
                        { x: timestamp, y: value },
                        ....
                    ]
                },
                { key : "Series 2", ... }
            ],
            weeklyLabels : [unixtimestamp-milliseconds, ts, ts, ...],
            monthlyLabels : [unixtimestamp-milliseconds, ts, ts, ...]
        }
     **/
    function getData () {

        var rawData = JSON.parse( $('#server-performance-data').text() );

        rawData[0].color = "#4B70E7";

        // rawData.push( {
        //     key: "7-Day Moving Average",
        //     values: getMovingAverage( rawData[0].values, 7 ),
        //     color: "#FFBB44"
        // } );

        // rawData.push( {
        //     key: "28-Day Moving Average",
        //     values: getMovingAverage( rawData[0].values, 28 ),
        //     color: "#FF0000"
        // } );

        // rawData.push( {
        //     key: "20-Weekday Moving Average (no weekends)",
        //     values: getMovingAverage( rawData[0].values, 20, true ),
        //     color: "#00FF00"
        // } );

        return { dailyHits : rawData };

    }


    nv.addGraph(function() {

        window.hitsData = getData();
        console.log(hitsData);
        window.chart = nv.models.lineWithFocusChart();

        chart.xAxis
            .tickFormat(function(d) {
                return d3.time.format('%x %X')(new Date(d))
            });

        chart.x2Axis
            .tickFormat(function(d) {
                return d3.time.format('%x')(new Date(d))
            });

        chart.yAxis
            .tickFormat(d3.format(',.1f'));

        chart.y2Axis
            .tickFormat(d3.format(',.0f'));

        d3.select('#server-performance-plot svg')
            .datum( hitsData.dailyHits )
            .attr( "height" , $(window).height() - 100 )
            .transition().duration(500)
            .call(chart);

        // $("#server-performance-chart svg").height( $(window).height() - 100 );

        nv.utils.windowResize(chart.update);

        return chart;
    });
});

