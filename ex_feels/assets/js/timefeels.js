function addAxes (svg, xAxis, yAxis, chartHeight, name) {

  var axes = svg.append('g')
    .attr('clip-path', 'url(#axes-clip)');

  axes.append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + chartHeight + ')')
    .call(xAxis)
  .selectAll("text")
    .attr("transform", "rotate(45)")
    .style("text-anchor", "start");

  axes.append('g')
    .attr('class', 'y axis')
    .call(yAxis)
    .append('text')
      .attr('transform', 'translate(-10,' + chartHeight/2 + ')rotate(-90)')
      .attr('y', 0)
      .style('text-anchor', 'middle')
      .text('Sentiment')
}

function drawPaths (svg, data, x, y) {

  var Area = d3.svg.area()
    .interpolate('basis')
    .x (function (d) { return x(d.time) || 1; })
    .y0(function (d) { return y(d.mean + d.std**2); }) // use variance instad
    .y1(function (d) { return y(d.mean - d.std**2); });// of std deviation
  
  var meanLine = d3.svg.line()
    .interpolate('basis')
    .x(function (d) { return x(d.time); })
    .y(function (d) { return y(d.mean); });

  // append the gradient 
  var uGradient = svg.append("defs")
    .append("linearGradient")
    .attr("gradientUnits", "objectBoundingBox")
    .attr("id", "upperGradient")
    .attr("x1", "0%")
    .attr("x2", "0%")
    .attr("y1", 1)
    .attr("y2", -1)
    .attr("spreadMethod", "pad");

  uGradient.append("stop")
    .attr("offset", 0)
    .attr("stop-color", "#ff3860")
    .attr("stop-opacity", 0.95);

  uGradient.append("stop")
    .attr("offset", 0.25)
    .attr("stop-color", "#a4a4a4")
    .attr("stop-opacity", 0.85);

  uGradient.append("stop")
    .attr("offset", 0.5)
    .attr("stop-color", "#23d160")
    .attr("stop-opacity", 0.95);  

  svg.datum(data);

  svg.append('path') // add variance cloud
    .attr('class', 'area inner')
    .attr('d', Area)
    .attr('fill', 'url(#upperGradient)')
    .attr('clip-path', 'url(#rect-clip)');

  svg.append('path') // add mean trend
    .attr('class', 'mean-line')
    .attr('d', meanLine)
    .attr('clip-path', 'url(#rect-clip)');
}

function startTransitions (chartWidth, rectClip) {
  rectClip.transition().attr('width', chartWidth);
}

function makeChart (data, name) {

  var svgWidth  = 1200,
      svgHeight = 500,
      margin = { top: 30, right: 20, bottom: 50, left: 50 },
      chartWidth  = svgWidth  - margin.left - margin.right,
      chartHeight = svgHeight - margin.top  - margin.bottom;

  var x = d3.time.scale().range([0, chartWidth])
            .domain(d3.extent(data, function (d) { return d.time; })),
      y = d3.scale.linear().range([chartHeight, 0])
            .domain([-1, 1]);

  var xAxis = d3.svg.axis().scale(x).orient('bottom')
                .innerTickSize(-chartHeight).outerTickSize(0).tickPadding(10)
                .tickFormat(d3.time.format("%b %d")),
      yAxis = d3.svg.axis().scale(y).orient('left')
                .innerTickSize(-chartWidth).outerTickSize(0).tickPadding(10)
                .tickValues([-1,0,1])
                .tickFormat(d => ["😭", "", "🤑"][d+1]);

  var svg = d3.select('#timefeels').append('svg')
    .attr('width',  svgWidth)
    .attr('height', svgHeight)
    .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  // clipping to start chart hidden and slide it in later
  var rectClip = svg.append('clipPath')
    .attr('id', 'rect-clip')
    .attr('fill', 'url(#upperGradient)')
    .append('rect')
      .attr('width', 0)
      .attr('height', chartHeight);
  
  svg.append("text") // add chart title
      .attr("x", (chartWidth / 2))             
      .attr("y", 0 - (margin.top / 20))
      .attr("text-anchor", "middle")  
      .style("font-size", "20px")
      .style('font-weight', 'bold')
      .text(name);

  addAxes(svg, xAxis, yAxis, chartHeight, name);
  drawPaths(svg, data, x, y);
  startTransitions(chartWidth, rectClip);
}

// Hit the bitfeels api for stats, log and make chart
const url = "/bitfeels/api/stats"
d3.json(url, function (classifiers) {
  classifiers.forEach(function (classifier) {
    makeChart(classifier.data, classifier.name);
  });
});
