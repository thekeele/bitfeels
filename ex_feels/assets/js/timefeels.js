function addAxes (svg, xAxis, yAxis, chartHeight) {
  var axes = svg.append('g')
    .attr('clip-path', 'url(#axes-clip)');

  axes.append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + chartHeight/2 + ')')
    .call(xAxis)

  axes.append('g')
    .attr('class', 'y axis')
    .call(yAxis)
    .append('text')
      .attr('transform', 'rotate(-90)')
      //.attr('transform', 'translate(0,' + chartHeight/2 + ')')
      .attr('y', 0)
      .attr('dy', '-2em')
      .attr('dx', '-4em')
      .style('text-anchor', 'end')
      .text('Sentiment');
}

function drawPaths (svg, data, x, y) {

  var upperArea = d3.svg.area()
    .interpolate('basis')
    .x (function (d) { return x(d.time) || 1; })
    .y0(function (d) { return y(d.mean) + y(d.std); })
    .y1(function (d) { return y(d.mean); });
  
  var meanLine = d3.svg.line()
    .interpolate('linear')
    .x(function (d) { return x(parseTime(d.time)); })
    .y(function (d) { return y(d.mean); });

  var lowerArea = d3.svg.area()
    .interpolate('basis')
    .x (function (d) { return x(parseTime(d.time)) || 1; })
    .y0(function (d) { return y(d.mean); })
    .y1(function (d) { return y(d.mean) - y(d.std); });

  svg.datum(data);

  svg.append('path')
    .attr('class', 'area upper inner')
    .attr('d', upperArea)
    .attr('clip-path', 'url(#rect-clip)');

  svg.append('path')
    .attr('class', 'area lower inner')
    .attr('d', lowerArea)
    .attr('clip-path', 'url(#rect-clip)');

  svg.append('path')
    .attr('class', 'median-line')
    .attr('d', meanLine)
    .attr('clip-path', 'url(#rect-clip)');
}

function startTransitions (chartWidth, rectClip) {
  rectClip.transition().attr('width', chartWidth);
}

function makeChart (data) {

  var svgWidth  = 1024,
      svgHeight = 450,
      margin = { top: 20, right: 20, bottom: 40, left: 40 },
      chartWidth  = svgWidth  - margin.left - margin.right,
      chartHeight = svgHeight - margin.top  - margin.bottom;

  var x = d3.time.scale().range([0, chartWidth])
            .domain(d3.extent(data, function (d) { return parseTime(d.time); })),
      y = d3.scale.linear().range([chartHeight, 0])
            .domain([-1, 1]);

  var xAxis = d3.svg.axis().scale(x).orient('bottom')
                .innerTickSize(-chartHeight).outerTickSize(0).tickPadding(10),
      yAxis = d3.svg.axis().scale(y).orient('left')
                .innerTickSize(-chartWidth).outerTickSize(0).tickPadding(10);

  var svg = d3.select('#timefeels').append('svg')
    .attr('width',  svgWidth)
    .attr('height', svgHeight)
    .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  // clipping to start chart hidden and slide it in later
  var rectClip = svg.append('clipPath')
    .attr('id', 'rect-clip')
    .append('rect')
      .attr('width', 0)
      .attr('height', chartHeight);
  addAxes(svg, xAxis, yAxis, chartHeight);
  drawPaths(svg, data, x, y);
  startTransitions(chartWidth, rectClip);
}

var parseTime = d3.time.format('%a %b %d %H:%M:%S %Z %Y').parse;

// Hit the bitfeels api for stats, log and make chart
var url = "/bitfeels/api/stats"
var response = d3.json(url, function (json) {
  console.log(json);
  makeChart(json);
});
