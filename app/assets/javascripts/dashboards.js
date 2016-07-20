;(function() {
    var sum = function(numberArray) {
      return _(numberArray).reduce(function(memo, num) {
        return memo + num;
      }, 0);
    }


  var selectMetricsForDateRange = function(startDate, endDate) {
    //console.log('dates being passed in', startDate, endDate);
    // You MUST call #startOf('day') when calling #diff. If you do not, you get
    // random (about 1 / 40) off-by-one errors. Additionally, you must call
    // startOf on the other operand to standardize the input ranges.
    var startIndex = moment().startOf('day').diff(startDate.startOf('day'), 'days');
    var endIndex = moment().startOf('day').diff(endDate.startOf('day'), 'days');
    //console.log('calculated indexs', startIndex, endIndex);
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

  var dateRangeInitialStartDate = moment().startOf('month');
  var dateRangeInitialEndDate = moment();
  var dateRangeInitialMetrics = selectMetricsForDateRange(dateRangeInitialStartDate,
                                                          dateRangeInitialEndDate);

  var dateRangePickerCallback = function(startDate, endDate, label) {
    var dateRangeMetrics = selectMetricsForDateRange(startDate, endDate);
    var periodLabels = generatePeriodLabels(startDate, endDate);
    _([ leadsChart,
        costChart,
        impressionsChart,
        clickThroughRateChart,
        clicksChart,
        conversionRateChart ]
     ).map(function(chart) {
        updateChart(chart, dateRangeMetrics, periodLabels);
     });
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
  }, dateRangePickerCallback);


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
      _($('.leads-widget .chart-summary-metric'))
        .zip([totalLeads, formLeads, callLeads])
        .map(function(pair) {
          $(pair[0]).text(pair[1]);
        });
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

      _($('.cost-widget .chart-summary-metric'))
        .zip([cost, costPerLead])
        .map(function(pair) {
          $(pair[0]).text('$' + pair[1].toFixed(2));
        });
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

      _($('.impressions-widget .chart-summary-metric'))
        .zip([impressions])
        .map(function(pair) {
          $(pair[0]).text(pair[1]);
        });
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
      var clickThroughRate = clicks / impressions;

      _($('.click-through-rate-widget .chart-summary-metric'))
        .zip([clickThroughRate])
        .map(function(pair) {
          $(pair[0]).text((pair[1] * 100).toFixed(2) + "%");
        });
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
      _($('.clicks-widget .chart-summary-metric'))
        .zip([clicks])
        .map(function(pair) {
          $(pair[0]).text(pair[1]);
        });
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
      var conversionRate = conversions / clicks;
      $('.conversion-rate-widget .chart-summary-metric').text((conversionRate * 100).toFixed(2) + "%")
      //_($('.clicks-widget .chart-summary-metric'))
        //.zip([clicks])
        //.map(function(pair) {
          //$(pair[0]).text(pair[1]);
        //});
    },
    metricsLabels: 'conversionRate'
  });

  var google_ad_position_chart = createChart('.google-ad-position-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Ad Position',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  var google_cpc_chart = createChart('.google-cpc-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  var google_conversion_rate_chart = createChart('.google-conversion-rate-chart',
                                                  sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  var google_ctr_chart = createChart('.google-ctr-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  var bing_ad_position_chart = createChart('.bing-ad-position-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Ad Position',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  var bing_cpc_chart = createChart('.bing-cpc-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  var bing_conversion_rate_chart = createChart('.bing-conversion-rate-chart',
                                                  sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  var bing_ctr_chart = createChart('.bing-ctr-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost per Click',
          data: [ 1.2, 1.3, 1.3, 1.1, 1, 1.3,
                  1.4, 1, 1.6, 1.7, 1.3, 1.3,
                  1.2, 1.5, 1.1, 1, 1.3, 1.3,
                  1.2, 1.2, 1.2, 1.2, 1.3, 1.3,
                  1.6, 1.1, 1.4, 1.1, 1.3, 1.2, 1.3 ]
        }
      ]
    }
  });

  // Updates the initialized, but empty charts with the initial, pre-selected date range
  dateRangePickerCallback(dateRangeInitialStartDate, dateRangeInitialEndDate);

  // Sorts the Marchex table by the most recent call (5th column)
  $("[data-sort=table]").tablesorter({
    sortList: [[4,1]]
  });

}());
