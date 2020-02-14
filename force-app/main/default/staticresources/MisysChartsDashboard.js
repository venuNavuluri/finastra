var Misys = Misys || {};
Misys.Dashboard = (function ($) {

  var loadCharts = function () {
    for (var i = 0; i < this.chartData.length ; i+=1) {
      //creating a new chart passing the chart id
      this.charts.push(new Misys.Chart(this.chartData[i]));
    }
  };

  // only required if the entire dashboard was to be loaded in dynamically
  var loadDashboard = function () {
    //NO-OP
  };

  var update = function (args) {
    this.charts.forEach( function(el) {
      el.loadChart(args);
    });
  };

  var Dashboard = function () {
    var args = Array.prototype.slice.call(arguments).pop();
    this.charts = [];
    //if arguments passed in was array, this represents an
    //array of ids for charts.
    //if its a string, that represents the id of a dashboard to look up
    if (args !== undefined && args.constructor === Array) {
      this.chartData = args;
      this.loadCharts();
    }
     // else {
      // dashboardId = args;
      // initDashboard();
    // }
  };

  Dashboard.prototype = {
    constructor: Misys.Dashboard,
    version: '0.2',
    loadCharts: loadCharts,
    loadDashboard: loadDashboard,
    update: update
  };

  return Dashboard;

}(jQuery));


Misys.Chart = (function ($) {

  //private
  var updatePostData = function (filter) {
    var self = this;
    var postData;
    if (self.postData === null) {
      return null;
    }

    postData = $.extend(true, {}, self.postData);
    $.each(postData.reportMetadata.reportFilters, function (i, el) {
      if (el.column.toLowerCase() === filter.column.toLowerCase()) {

        //if the select was cleared
        if (filter.value === 'null') {
          el.operator = self.initialPostData.reportMetadata.reportFilters[i].operator;
          el.value = self.initialPostData.reportMetadata.reportFilters[i].value;
        } else {
          el.operator = 'equals';
          el.value = filter.value;
        }
        // break the $.each loop
        return false;
      }
    });

    return postData;
  };

  // var addTitle = function (response) {
  //   var titleLink = $('<a title="View the full report" href="/'+ response.attributes.reportId +'">'+ response.attributes.reportName +'</a>');
  //   $('.title', this.domId).append(titleLink);
  // };

  var showLoadIcon = function (show) {
    var icon = $('<span class="load-icon">loading</span>');
    if ($('.load-icon', this.domId).length === 0) {
      $(this.domId).append(icon);
    }

    if (show) {
      $('.load-icon', this.domId).addClass('active');
    } else {
      $('.load-icon', this.domId).removeClass('active');
    }
  };

  var draw = function (response) {

    if (this.renderChart !== null) {
      this.renderChart(response, this.domId);
    }

    // if ($('.title a', this.domId).length === 0) {
    //   this.addTitle(response);
    // }
    // $(this.domId).find('svg').on('click', function () {
    //   window.location.href = '/' + response.attributes.reportId;
    // });

  };

  var loadChart = function (filter) {
    var postData, self = this;

    //if an updated filter was passed in,
    //update the postData to match otherwise reset the post data
    //and get the original chart
    if (filter !== undefined) {
      self.postData = updatePostData.apply(self, [filter]);
    } else {
      self.postData = self.initialPostData;
    }

    self.showLoadIcon(true);

    $.when(self.proxy.loadData(self.id, self.postData))
      .done(function (data, textStatus, jqXHR) {
        self.draw(data);

        if (self.postData === null && data.reportMetadata !== undefined) {
          self.postData = { reportMetadata: data.reportMetadata };
          self.initialPostData = $.extend(true, {}, self.postData);
        }
        // else {
        //   self.postData = postData;
        // }
      })
      .fail(function (error) {
        console.log(error);
      })
      .always(function () {
        self.showLoadIcon(false);
      });
  };

  var Chart = function () {
    this.chartData = Array.prototype.slice.call(arguments).pop() || {};
    this.id = this.chartData.id || '';
    this.postData = this.chartData.postData || null;
    this.initialPostData = this.postData !== null ? $.extend(true, {}, this.postData) : null;
    this.domId = this.chartData.domId || '';
    this.renderChart = this.chartData.renderChart || null;

    this.endPoint = Misys.endPoint !== undefined ? Misys.endPoint.replace('%i', this.id) : '';
    this.proxy = new Misys.ReportingProxy(this.endPoint);
    this.loadChart();
  };

  Chart.prototype = {
    constructor: Misys.Chart,
    version: '0.6',
    loadChart: loadChart,
    showLoadIcon: showLoadIcon,
    // addTitle: addTitle,
    draw: draw
  };

  return Chart;

}(jQuery));

//all requests to the api go through the proxy,
//if data already exists in the cache, return that
Misys.ReportingProxy = (function ($, Cookies) {

  var getCacheKey = function (id, data) {
    if (data === null) {
      return id;
    }

    return data.reportMetadata.reportFilters.reduce(function (prev, curr) {
      return (prev.value || prev) + '-' + curr.value;
    }, id);
  };

  var getCachedData = function (cacheKey) {
    if (this.cache[cacheKey] !== undefined) {
      return this.cache[cacheKey];
    }

    return undefined;
  };

  var cacheData = function (cacheKey, response) {
    this.cache[cacheKey] = response;
  };

  var requestInstancePost = function (postData) {
    var self = this;
    var xhr = $.ajax(this.endPoint,
    {
      type: window.location.href.indexOf('localhost') === -1 ? 'POST' : 'GET',
      cache: false,
      beforeSend: function(xhr) {
        self.loadingTimer = new Date();
        xhr.setRequestHeader('Authorization', 'Bearer ' + Misys.authKey || '');
        xhr.setRequestHeader('Content-Type', 'application/json');
      },
      data: postData === null ? null : JSON.stringify(postData)
    });

    xhr
      .done (function (response) {

        // this can be set anywhere but is set usually from the calling page
        // where the dashboard is instantiated
        if (Misys.debug) {
          console.log('\n------async response------\n');
          console.log(response);
        }
      })
      .fail (function (jqXHR) {
        console.log(jqXHR.responseText);
      });

    return xhr;

  };

  var requestInstanceGet = function (url) {
    var xhr = $.ajax((Misys.sitePrefix || '') + url,
    {
      type: 'GET',
      cache: false,
      beforeSend: function(xhr) {
        xhr.setRequestHeader('Authorization', 'Bearer ' + Misys.authKey || '');
        xhr.setRequestHeader('Content-Type', 'application/json');
      }
    });

    return xhr;

  };

  // loadData uses salesforces' async request method which has higher api limits
  // https://developer.salesforce.com/docs/atlas.en-us.api_analytics.meta/api_analytics/sforce_analytics_rest_api_get_reportdata.htm
  // the first ajax call generates the report instance using the postData
  // the second call gets the instance then caches it

  // n.b - if limits are still being hit, we'll need to look at something like setting cookies or localStorage if available
  var loadData = function (id, postData) {
    var self,
      cacheKey,
      cachedData,
      xhr,
      instanceXhr,
      instanceUrl,
      instanceGetCount,
      doneHandler,
      tInterval,
      deferred;

    self = this;
    deferred = $.Deferred();

    // used to only try to get the instance max of n times then stop and show error
    instanceGetCount = 0;

    cacheKey = getCacheKey(id, postData);
    cachedData = this.getCachedData(cacheKey);
    if (cachedData !== undefined) {
      return cachedData;
    }

    //check that cookie doesn't exist for the report instance using the cache key
    // if (Cookies.get(cacheKey) !== undefined) {

    // }

    //called when GET request made to get report instance
    //if status is not success, repoll the instance after 2 seconds
    doneHandler = function (response) {
      if (response.attributes.status.toLowerCase() !== 'success' && instanceGetCount < self.instanceGetCountThreshold) {

        instanceGetCount += 1;
        tInterval = setTimeout(function () {
          requestInstanceGet(instanceUrl).done(doneHandler);
        }, self.pollRate);

      } else {

        clearTimeout(tInterval);

        // if status is 'error' clear the timeout, show a message and clear any related cookie
        if (response.attributes.status.toLowerCase() === 'error') {
          deferred.reject('Error getting the report instance');
          return;
        }

        // show error about too long loading
        if (instanceGetCount >= self.instanceGetCountThreshold) {
          deferred.reject('Slow response, try again later');
          return;
        }

        var finalTime = new Date();
        self.loadingTimer = (finalTime - self.loadingTimer)/1000;


        // else cache and log the data
        // and create a 24hr cookie using the cachekey and instance url
        self.cacheData(cacheKey, response);
        // Cookies.set(cacheKey, instanceUrl, { expires: 1 });

        //resolve the data
        deferred.resolve(response);

        if (Misys.debug) {

          console.log('\n-----instance data----\n');
          console.log(response);
          console.log('\n-----time taken to load (s)----\n');
          console.log(self.loadingTimer);
        }
      }
    };

    // if the instance url exists as a cookie, get that and load it straight away
    // rather than first performing the post request
    xhr = Cookies.get(cacheKey) === undefined ?
      requestInstancePost.apply(self, [postData]) :
      $.Deferred().resolve({
        url: Cookies.get(cacheKey)
      });

    $.when(xhr).then(function (response) {
      instanceUrl = response.url;
      instanceXhr = requestInstanceGet (instanceUrl);

      instanceXhr
        .done (doneHandler)
        .fail (function (jqXHR) {
          console.log(jqXHR);
          deferred.reject(jqXHR.statusText);
        });


    });

    return deferred;

  };

  var ReportingProxy = function (endPoint) {
    this.cache = {};
    this.endPoint = endPoint;
    this.instanceGetCountThreshold = Misys.instanceGetCountThreshold || 5;
    this.pollRate = Misys.pollRate || 2000;
    this.loadingTimer = new Date();
  };

  ReportingProxy.prototype = {
    constructor: Misys.ReportingProxy,
    version: '0.9',
    cacheData: cacheData,
    loadData: loadData,
    getCachedData: getCachedData
  };

  return ReportingProxy;

})(jQuery, Cookies);

//strategies for rendering charts, means that can develop other solutions
//if needed
Misys.ChartEngines = {};
Misys.ChartEngines.NVD3 = (function (nv, d3) {

  var renderers = {
    Column: function (response, domId) {
      var chart = nv.models.multiBarChart()
        .margin({ left: 100 })
        .stacked(true)
        .staggerLabels(true);


      var xAxisObject = response.reportMetadata.groupingsAcross.length > 0 ? response.reportMetadata.groupingsAcross[0].name : null;
      var xAxis = response.reportExtendedMetadata.groupingColumnInfo[xAxisObject] || null;

      chart.xAxis
        .axisLabel(xAxis !== null ? xAxis.label : '');

      var yAxisObject = response.reportMetadata.aggregates.length > 0 ? response.reportMetadata.aggregates[0] : null;
      var yAxis = response.reportExtendedMetadata.aggregateColumnInfo[yAxisObject] || null;

      chart.yAxis
        .axisLabel(yAxis !== null ? yAxis.label : '');

      var chartData = [];
      $.each(response.groupingsDown.groupings, function(di, de) {
        var values = [];
        chartData.push({"key":de.label, "values": values});
        $.each(response.groupingsAcross.groupings, function(ai, ae) {
          values.push({"x": ae.label, "y": response.factMap[de.key+"!"+ae.key].aggregates[0].value});
        });
      });

      d3.select(domId + ' svg')
        .datum(chartData)
        .transition()
        .duration(500)
        .call(chart);

      nv.utils.windowResize(chart.update);
    },
    //ISSUES
    /*
    not sure how to set tick count
    not sure how to set format of axis. the selected line chart requires % against date
    but I can't see this anywhere in the json data. would this need hard-coding?
    Also since the x-axis is date, each value for the groupingsAcross x property need to be
      parsed as dates. this obviously wouldn't work for other line charts.
      could use reportExtendedMetadata.detailColumnInfo to look up column data types
    */
    Line: function (response, domId) {
      var chart = nv.models.lineChart()
      .margin({left: 100, right: 50})
      .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
      .showLegend(true)       //Show the legend, allowing users to turn on/off line series.
      .showYAxis(true)        //Show the y-axis
      .showXAxis(true);        //Show the x-axis

      chart.xAxis
        .axisLabel('Opened Date')
        //.ticks(2, 'M')
        .tickFormat(function(d) {
          return d3.time.format("%Y-%m-%d")(new Date(d));
        });

      chart.yAxis
        .axisLabel('%')
        .ticks(10)
        .tickFormat(function(d) {
          return d + '%';
      });

      var chartData = [];
      $.each(response.groupingsDown.groupings, function(di, de) {
        var values = [];
        chartData.push({"key":de.label, "values": values});
        $.each(response.groupingsAcross.groupings, function(ai, ae) {
          values.push({"x": new Date(ae.value), "y": response.factMap[de.key+"!"+ae.key].aggregates[0].value});
        });
      });
        //console.log(chartData);
      d3.select(domId + ' svg')
        .datum(chartData)
        .transition()
        .duration(500)
        .call(chart);

      nv.utils.windowResize(chart.update);

    },
    Donut: function (response, domId) {
      var chart = nv.models.pieChart()
        .x(function(d) {
          return d.label;
        })
        .y(function(d) {
          return d.value;
        })
        .showLabels(true)     //Display pie labels
        .labelThreshold(0.001)  //Configure the minimum slice size for labels to show up
        .labelType("percent") //Configure what type of data to show in the label. Can be "key", "value" or "percent"
        .showLegend(true)
        .donut(true)          //Turn on Donut mode. Makes pie chart look tasty!
        .donutRatio(0.4)     //Configure how big you want the donut hole size to be.
        // .labelSunbeamLayout(true) //causes radial display of labels in the segments
        .title('Total: ' + response.factMap['T!T'].aggregates[0].value)
        ;

      chart.valueFormat(d3.format('d'));
        //chart.pie.pieLabelsOutside(false).labelType("percent");

      var chartData = [];
      $.each(response.groupingsDown.groupings, function(di, de) {
        chartData.push({"label":de.label, "value": response.factMap[de.key + '!T'].aggregates[0].value});
      });

      d3.select(domId + ' svg')
        .datum(chartData)
        .transition()
        .duration(500)
        .call(chart);

      nv.utils.windowResize(chart.update);

    }

  };

  var NVD3 = function () {};
  NVD3.prototype = {
    constructor: Misys.ChartEngines.NVD3,
    version: '0.3',
    renderers: renderers
  };

  return NVD3;

}(nv, d3));
