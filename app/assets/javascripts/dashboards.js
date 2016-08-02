;(function() {
  var sum = function(numberArray) {
    return _(numberArray).reduce(function(memo, num) {
      return memo + num;
    }, 0);
  }


  // -- BEGIN CALL TABLE SETUP

  // Sets up Marchex Call Log table
  var marchexCallTable = $("#marchex_calls").DataTable({
    data: Icarus.marchexCalls,
    deferRender: true,
    lengthChange: false,
    //pageLength: 20,
    order: [[4, 'desc']],
    scrollX: false,
    autoWidth: false,
    responsive: {
      details: {
        type: 'inline',
        //target: 0
      }
    },
    columnDefs: [
      {
        targets: 0,
        sClass: 'text-nowrap',
        responsivePriority: 0,
        render: function(data, type, row) {
          if (data) {
            return data;
          } else {
            return "(No name on file)";
          }
        }
      },
      {
        targets: 1,
        sClass: 'text-nowrap',
        responsivePriority: 4,
        render: function(data, type, row) {
          if ( type === 'display' ) {
            if (data.length === 10) {
              return '('+data.slice(0,3)+') '+data.slice(3,6)+'-'+data.slice(6);
            } else {
              return data;
            }
          } else {
            return data;
          }
        }
      },
      {
        targets: 2,
        sClass: 'text-nowrap',
        responsivePriority: 3,
      },
      {
        targets: 3,
        sClass: 'text-nowrap',
        responsivePriority: 5,
      },
      {
        targets: 4,
        sClass: 'text-nowrap',
        responsivePriority: 1,
        render: function(data, type, row) {
          if ( type === 'display' ) {
            return moment(data).format('hh:mm a, MMM Do');
          } else {
            return data;
          }
        }
      },
      {
        targets: 5,
        responsivePriority: 2,
      },
      {
        targets: 6,
        responsivePriority: 6,
      },
      {
        targets: 7,
        sClass: 'text-xs-center',
        responsivePriority: 7,
        render: function(data, type, row) {
          if (data) {
            return '<audio controls src="'+data+'" type="audio/mp3" preload="none">';
          } else {
            return "No Recording";
          }
        }
      }
    ]
  });

  // Date filter function. Slow.
  $.fn.dataTable.ext.search.push(
    function( settings, renderData, dataIndex, originalData ) {
      var rowDateTime = moment(renderData[4]);
      if ( rowDateTime.isAfter(marchexCallTable.startDate)
           &&
           rowDateTime.isBefore(marchexCallTable.endDate.endOf('day')) )
        return true;
      else {
        return false;
      }
    }
  );

  // Have the call log only search on "enter"
  $('#marchex_calls_filter input').unbind().on('keyup', function(e) {
    if (e.keyCode === 13) {
      marchexCallTable.search(this.value).draw();
    }
  });

  // -- END CALL TABLE SETUP


  // -- BEGIN DATEPICKER SETUP

  // Given a pair of dates, returns the corresponding metrics subsection
  var selectMetricsForDateRange = function(startDate, endDate) {
    // You MUST call #startOf('day') when calling #diff. If you do not, you get
    // random (about 1 / 40) off-by-one errors. Additionally, you must call
    // startOf on the second operand to standardize the input ranges.
    var startIndex = moment().startOf('day').diff(startDate.startOf('day'), 'days');
    var endIndex = moment().startOf('day').diff(endDate.startOf('day'), 'days');
    return _.mapObject(Icarus.metrics, function(metricsArray, metricsName) {
      // These are negative because the most recent data is at the end.
      // Subtraction accounts for non-inclusive slice.
      if (endIndex === 0) {
        return metricsArray.slice(-startIndex - 1);
      } else {
        return metricsArray.slice(-startIndex - 1, -endIndex);
      }
    });
  };

  var generateDateRange = function(startDate, endDate) {
    var numberOfDays = endDate.startOf('day').diff(startDate.startOf('day'), 'days') + 1;
    return _.times(numberOfDays, function(n) {
      return startDate.clone().add(n, 'days');
    });
  };

  var generatePeriodLabels = function(startDate, endDate) {
    return _.map(generateDateRange(startDate, endDate), function(mmnt){
      return mmnt.format('MMM D');
    });
  };

  var updateChart = function(chart, dateRangeMetrics, periodLabels) {
    chart.updateData(dateRangeMetrics);
    chart.data.labels = periodLabels;
    chart.update(500);
    chart.updateSummaryMetrics(dateRangeMetrics);
  };

  // Setting initial date range and associated sub-metrics
  var dateRangeInitialStartDate = moment().startOf('month');
  var dateRangeInitialEndDate = moment();
  var dateRangeInitialMetrics = selectMetricsForDateRange(dateRangeInitialStartDate,
                                                          dateRangeInitialEndDate);

  // Setting initial dates for Marchex Call Table filter function
  marchexCallTable.startDate = dateRangeInitialStartDate;
  marchexCallTable.endDate = dateRangeInitialEndDate;

  var onDatePick = function(startDate, endDate, label) {
    var selectedMetrics = selectMetricsForDateRange(startDate, endDate);
    var periodLabels = generatePeriodLabels(startDate, endDate);
    _(charts).map(function(chart) {
        updateChart(chart, selectedMetrics, periodLabels);
     });
     marchexCallTable.startDate = startDate;
     marchexCallTable.endDate = endDate;
     // If you call #draw naked, it noticibly holds up the datepicker selection and
     // chart animation. This lets that clear before filtering the dates. Still
     // a pause in scroll responsiveness though. Call table really should be
     // ajaxed rather than being passed all the call records.
     _.delay(marchexCallTable.draw, 500);
     getSearchMetrics(startDate, endDate);
  };

  $('input.date-picker').daterangepicker({
    locale: {
      format: 'MMM D, YYYY'
    },
    startDate: dateRangeInitialStartDate,
    endDate: dateRangeInitialEndDate,
    minDate: moment().subtract(1, 'years'),
    maxDate: moment(),
    opens: 'left',
    ranges: {
      "Today":          [ moment(), moment() ],

      "Week to date":   [ moment().startOf('week'), moment() ],

      "Last week":      [ moment().subtract(1, 'week').startOf('week'),
                          moment().startOf('week').subtract(1, 'day') ],

      "Month to date":  [ moment().startOf('month'), moment() ],

      "Last month":     [ moment().subtract(1, 'month').startOf('month'),
                          moment().startOf('month').subtract(1, 'day') ],

      "Last 30 days":   [ moment().subtract(30, 'days'),
                          moment().subtract(1, 'day') ],

      "Year to date":   [ moment().startOf('year'), moment() ]
    }
  }, onDatePick);

  // -- END DATEPICKER SETUP


  // -- BEGIN CHARTS SETUP

  // Selects all of the chart elements
  var $charts = $('.dashboard-chart');

  var charts = [];

  var createChart = function(selector, defaults, configuration) {
    var chart = new Chart(
      $charts.filter(selector),
      $.extend(true, {}, defaults, _.omit(configuration, 'updateSummaryMetrics'))
    );
    chart.updateSummaryMetrics = configuration.updateSummaryMetrics || _.noop;
    chart.updateData = function(dateRangeMetrics) {
      if (_.isArray(this.config.metricsLabels)) {
        _.each(this.config.metricsLabels, function(label, i) {
          this.data.datasets[i].data = dateRangeMetrics[label];
        }, this);
      } else {
        this.data.datasets[0].data = dateRangeMetrics[this.config.metricsLabels];
      }
    };
    charts.push(chart);
    return chart;
  };

  var chartDefaults = {
    data: {
      labels: generatePeriodLabels(dateRangeInitialStartDate, dateRangeInitialEndDate),
    },
    options: {
      legend: {
        display: false
      },
      scales: {
        xAxes: [{
          gridLines: {
            drawOnChartArea: false
          },
          ticks: {
            fontSize: 14,
            fontColor: 'rgba(0,0,0,.4)',
            //maxRotation: 0,
            //userCallback: function(value, index, values) {
              //var calculated_value = (index + 1) % 3 ? '' : value;
              //return calculated_value;
            //}
          }
        }],
        yAxes: [{
          type: "linear",
          ticks: {
            beginAtZero: true,
            fontSize: 14,
            fontColor: 'rgba(0,0,0,.4)'
          }
        }]
      }
    }
  };

  var lineDefaults = $.extend(true, {}, chartDefaults, {
    type: 'line',
    data: {
      datasets: [
        {
          lineTension : 0.25,
          pointRadius: 1,
          pointHitRadius: 15,
          borderWidth: 2,
          borderColor: '#1ca8dd',
          backgroundColor: 'rgba(28,168,221,0.03)'
        }
      ]
    }
  });

  var sparkLineDefaults = $.extend(true, {}, chartDefaults, {
    type: 'line',
    data: {
      datasets: [
        {
          lineTension : 0.25,
          pointRadius: 0,
          pointHoverRadius: 0,
          borderWidth: 2,
          borderColor: '#fff',
          backgroundColor: 'rgba(255,255,255,.3)'
        }
      ]
    },
    options: {
      tooltips: {
        enabled: false
      },
      scales: {
        xAxes: [{
          display: false
        }],
        yAxes: [{
          display: false
        }]
      }
    }
  });

  var leadsChart = createChart('.leads-chart', chartDefaults, {
    type: 'bar',
    data: {
      datasets: [
        {
          label: 'Calls',
          backgroundColor: '#1ca8dd',
          // Need this, otherwise something is changing the color on hover
          hoverBackgroundColor: '#1ca8dd',
          data: []
        },
        {
          label: 'Forms',
          backgroundColor: '#E64759',
          // Need this, otherwise something is changing the color on hover
          hoverBackgroundColor: '#E64759',
          data: []
        }
      ]
    },
    options: {
      tooltips: {
        // Combines the tooltips of the different datasets (Forms and Calls)
        mode: 'label'
      },
      scales: {
        xAxes: [{
          categoryPercentage: 0.6,
          barPercentage: 1.0,
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var callLeads = sum(this.data.datasets[0].data);
      var formLeads = sum(this.data.datasets[1].data);
      var totalLeads = callLeads + formLeads;
      var $summaryMetrics = $('.leads-widget .chart-summary-metric')
      $($summaryMetrics[0]).text(totalLeads);
      $($summaryMetrics[1]).text(formLeads);
      $($summaryMetrics[2]).text(callLeads);
    },
    metricsLabels: ['callConversions', 'formConversions']
  });

  var costChart = createChart('.cost-chart', lineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost',
          pointRadius: 3,
          pointHoverRadius: 7,
          data: []
        }
      ]
    },
    options: {
      tooltips: {
        callbacks: {
          label: function(tooltipItem, data) {
            return data.datasets[0].label + ": $" + tooltipItem.yLabel;
          }
        }
      },
      scales: {
        yAxes: [{
          ticks: {
            beginAtZero: false,
            userCallback: function(value, index, values) {
              return "$" + value;
            }
          }
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var cost = sum(this.data.datasets[0].data);
      var leads = sum(dateRangeMetrics.conversions);
      var costPerLead = cost / leads;
      var $summaryMetrics = $('.cost-widget .chart-summary-metric')
      $($summaryMetrics[0]).text('$' + cost.toFixed(2));
      $($summaryMetrics[1]).text('$' + costPerLead.toFixed(2));
    },
    metricsLabels: 'cost'
  });

  var impressionsChart = createChart('.impressions-chart', lineDefaults, {
    data: {
      datasets: [
        {
          label: 'Impressions',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var impressions = sum(this.data.datasets[0].data);
      $('.impressions-widget .chart-summary-metric').text(impressions);
    },
    metricsLabels: 'impressions'
  });

  var clickThroughRateChart = createChart('.click-through-rate-chart', lineDefaults, {
    data: {
      datasets: [
        {
          label: 'Click Through Rate',
          data: []
        }
      ]
    },
    options: {
      tooltips: {
        callbacks: {
          label: function(tooltipItem, data) {
            return data.datasets[0].label + ": " + tooltipItem.yLabel + "%";
          }
        }
      },
      scales: {
        yAxes: [{
          ticks: {
            userCallback: function(value, index, values) {
              return value + "%";
            }
          }
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.clicks);
      var impressions = sum(dateRangeMetrics.impressions);
      var clickThroughRate = 100 * clicks / impressions;
      $('.click-through-rate-widget .chart-summary-metric')
        .text(clickThroughRate.toFixed(2) + "%");
    },
    metricsLabels: 'clickThroughRate'
  });

  var clicksChart = createChart('.clicks-chart', lineDefaults, {
    data: {
      datasets: [
        {
          label: 'Clicks',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(this.data.datasets[0].data);
      $('.clicks-widget .chart-summary-metric').text(clicks);
    },
    metricsLabels: 'clicks'
  });

  var conversionRateChart = createChart('.conversion-rate-chart', lineDefaults, {
    data: {
      datasets: [
        {
          label: 'Conversion Rate',
          data: []
        }
      ]
    },
    options: {
      tooltips: {
        callbacks: {
          label: function(tooltipItem, data) {
            return data.datasets[0].label + ": " + tooltipItem.yLabel + "%";
          }
        }
      },
      scales: {
        yAxes: [{
          ticks: {
            userCallback: function(value, index, values) {
              return value + "%";
            }
          }
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.clicks);
      var conversions = sum(dateRangeMetrics.conversions);
      var conversionRate = 100 * conversions / clicks;
      $('.conversion-rate-widget .chart-summary-metric')
        .text(conversionRate.toFixed(2) + "%");
    },
    metricsLabels: 'conversionRate'
  });

  var adwordsAdPositionChart = createChart('.adwords-ad-position-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Average Ad Position',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var impressions = dateRangeMetrics.adwordsImpressions;
      var averagePositions = dateRangeMetrics.adwordsAveragePosition;
      var scaledImpressions = _.zip(impressions, averagePositions).map(function(pair) {
        return pair[0] * pair[1];
      });
      var averagePosition = sum(scaledImpressions) / sum(impressions);
      $('.adwords-ad-position-widget .chart-summary-metric')
        .text(averagePosition.toFixed(2));
    },
    metricsLabels: 'adwordsAveragePosition'
  });

  var adwordsCostPerClickChart = createChart('.adwords-cpc-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.adwordsClicks);
      var cost = sum(dateRangeMetrics.adwordsCost);
      var costPerClick = cost / clicks;
      $('.adwords-cpc-widget .chart-summary-metric')
        .text('$' + costPerClick.toFixed(2));
    },
    metricsLabels: 'adwordsAverageCostPerClick'
  });

  var adwordsClickThroughRateChart = createChart('.adwords-ctr-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Click Through Rate',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.adwordsClicks);
      var impressions = sum(dateRangeMetrics.adwordsImpressions);
      var clickThroughRate = 100 * clicks / impressions;
      $('.adwords-ctr-widget .chart-summary-metric')
        .text(clickThroughRate.toFixed(2) + "%");
    },
    metricsLabels: 'adwordsClickThroughRate'
  });

  var adwordsConversionRateChart = createChart('.adwords-conversion-rate-chart',
                                               sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Conversion Rate',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.adwordsClicks);
      var formConversions = sum(dateRangeMetrics.adwordsFormConversions);
      var conversionRate = 100 * formConversions / clicks;
      $('.adwords-conversion-rate-widget .chart-summary-metric')
        .text(conversionRate.toFixed(2) + "%");
    },
    metricsLabels: 'adwordsConversionRate'
  });

  var bingadsAdPositionChart = createChart('.bingads-ad-position-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Ad Position',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var impressions = dateRangeMetrics.bingadsImpressions;
      var averagePositions = dateRangeMetrics.bingadsAveragePosition;
      var scaledImpressions = _.zip(impressions, averagePositions).map(function(pair) {
        return pair[0] * pair[1];
      });
      var averagePosition = sum(scaledImpressions) / sum(impressions);
      $('.bingads-ad-position-widget .chart-summary-metric')
        .text(averagePosition.toFixed(2));
    },
    metricsLabels: 'bingadsAveragePosition'
  });

  var bingadsCostPerClickChart = createChart('.bingads-cpc-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.bingadsClicks);
      var cost = sum(dateRangeMetrics.bingadsCost);
      var costPerClick = cost / clicks;
      $('.bingads-cpc-widget .chart-summary-metric')
        .text('$' + costPerClick.toFixed(2));
    },
    metricsLabels: 'bingadsAverageCostPerClick'
  });

  var bingadsClickThroughRateChart = createChart('.bingads-ctr-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.bingadsClicks);
      var impressions = sum(dateRangeMetrics.bingadsImpressions);
      var clickThroughRate = 100 * clicks / impressions;
      $('.bingads-ctr-widget .chart-summary-metric')
        .text(clickThroughRate.toFixed(2) + "%");
    },
    metricsLabels: 'bingadsClickThroughRate'
  });

  var bingadsConversionRateChart = createChart('.bingads-conversion-rate-chart',
                                               sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Conversion Rate',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var clicks = sum(dateRangeMetrics.bingadsClicks);
      var formConversions = sum(dateRangeMetrics.bingadsFormConversions);
      var conversionRate = 100 * formConversions / clicks;
      $('.bingads-conversion-rate-widget .chart-summary-metric')
        .text(conversionRate.toFixed(2) + "%");
    },
    metricsLabels: 'bingadsConversionRate'
  });

  // -- END CHARTS SETUP


  // -- BEGIN AD NETWORK SETUP

  var updateAdNetwork = function(searchMappings, selector) {
    var countTotal = sum(_.values(searchMappings));
    _($(selector)).zip(_.pairs(searchMappings)).map(function(pair, index) {
      var $spans = $(pair[0]).find('span');
      var kqStr, count;
      // Accounts for when there are fewer than 6 keyword mappings.
      if (pair[1] !== undefined) {
        kqStr = index + 1 + ". " + pair[1][0];
        count = pair[1][1];
      } else {
        kqStr = '-----';
        count = 0;
      }
      // denominator + 0.1 is to account for 0/0 -> NaN.
      $($spans[0]).css('width', (100 * count/(countTotal + 0.1)).toFixed(0) + "%");
      if (count === 0) {
        $($spans[1]).text('-');
      } else {
        $($spans[1]).text(count);
      }
      $($spans[2]).text(kqStr);
    });
  };

  var getSearchMetrics = function(startDate, endDate) {
    var base_url = window.location.href;
    if (base_url.slice(-1) === '\\') {
      base_url = base_url.slice(0, -1);
    }
    var resource_url = base_url
      + "/ad_network_metrics?start="
      + startDate.format("D-M-YYYY")
      + "&end="
      + endDate.format("D-M-YYYY");

    $.get(resource_url, function(adNetworkMetrics) {
      updateAdNetwork(adNetworkMetrics.adwordsKeywordConversions,
                      '.adwords-ad-network .keyword-conversions .list-group-item');
      updateAdNetwork(adNetworkMetrics.adwordsQueryClicks,
                      '.adwords-ad-network .query-clicks .list-group-item');
    });
  }

  // -- END AD NETWORK SETUP

  // Updates the initialized, but empty charts with the initial, pre-selected date range
  onDatePick(dateRangeInitialStartDate, dateRangeInitialEndDate);

}());
