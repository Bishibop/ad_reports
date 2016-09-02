;(function() {
  var sum = function(numberArray) {
    return _(numberArray).reduce(function(memo, num) {
      return memo + num;
    }, 0);
  };


  // -- BEGIN CALL TABLE SETUP

  // Sets up Marchex Call Log table
  var marchexCallTable = $('#marchex_calls').DataTable({
    pagingType: 'full_numbers',
    // Make the columns' visibility work correctly with responsive breakpoints
    drawCallback: function(settings) {
      this.api().columns.adjust().responsive.recalc();
    },
    deferLoading: 0,
    deferRender: true,
    lengthChange: false,
    pageLength: 10,
    searching: true,
    order: [[4, 'desc']],
    // Makes the table display and resize properly. No idea why. Technically, this
    // shouldn't do anything at all without specifying column specific widths...
    autoWidth: false,
    responsive: {
      details: {
        type: 'inline'
      }
    },
    language: {
      processing: 'Fetching calls...',
      emptyTable: 'No call data available.',
      info: 'Showing _START_ to _END_ of _TOTAL_ calls.',
      infoEmpty: 'Showing 0 to 0 of 0 calls.',
      infoFiltered: ''
    },
    columnDefs: [
      {
        targets: 0,
        responsivePriority: 0,
        render: function(data, type, row) {
          if (data) {
            return data;
          } else {
            return '(No name on file)';
          }
        }
      },
      {
        targets: 1,
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
        responsivePriority: 3,
      },
      {
        targets: 3,
        responsivePriority: 5,
      },
      {
        targets: 4,
        responsivePriority: 1,
        searchable: false
      },
      {
        targets: 5,
        responsivePriority: 2,
        searchable: false,
      },
      {
        targets: 6,
        responsivePriority: 6,
      },
      {
        targets: 7,
        sClass: 'text-xs-center',
        responsivePriority: 7,
        orderable: false,
        searchable: false,
        render: function(data, type, row) {
          if (data) {
            return '<audio controls src="'+data+'" type="audio/mp3" preload="none">';
          } else {
            return 'No Recording';
          }
        }
      }
    ]
  });

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

  var generateXAxisDateLabels = function(startDate, endDate) {
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

  var urlManager = {
    backToggle: false,
    initialParse: function() {
      if (location.search !== '') {
        try {
          var queryParams = _(location.search.slice(1).split('&')).reduce(function(memo, stringPair) {
            var pair = stringPair.split('=');
            memo[pair[0]] = pair[1];
            return memo;
          }, {});
          var unvalidatedStartDate = moment(queryParams.startDate, 'M-D-YYYY');
          var unvalidatedEndDate = moment(queryParams.endDate, 'M-D-YYYY');
          if (unvalidatedStartDate.isValid() &&
              unvalidatedEndDate.isValid() &&
              unvalidatedStartDate.isSameOrBefore(unvalidatedEndDate) &&
              unvalidatedEndDate.isSameOrBefore(moment())) {
            initializer.startDate = unvalidatedStartDate;
            initializer.endDate = unvalidatedEndDate;
            this.setDatePickerDates(unvalidatedStartDate, unvalidatedEndDate);
          } else {
            throw {
              name: 'DateParameterError',
              message: 'Invalid date query params'
            };
          }
        } catch (e) {
          console.log(e);
          // Something went wrong. Do nothing.
        }
      } else {
        // No params in URL. Do nothing.
      }
    },
    pushNewState: function(startDate, endDate) {
      if (history.pushState && !this.backToggle) {
        var datePeriodStringMapping = {
          startDate: startDate.format('M-D-YYYY'),
          endDate: endDate.format('M-D-YYYY')
        };
        history.pushState(
          datePeriodStringMapping,
          'Dashboard',
          _(location.pathname.slice(1).split('/')).last() + '?' + $.param(datePeriodStringMapping)
        );
      } else {
        this.backToggle = false;
      }
    },
    popOldState: function() {
      if (history.state) {
        var previousStartDate = moment(history.state.startDate, 'M-D-YYYY');
        var previousEndDate = moment(history.state.endDate, 'M-D-YYYY');
        this.setDatePickerDates(previousStartDate, previousEndDate);
        this.backToggle = true;
        onDatePick(previousStartDate, previousEndDate);
      } else {
        history.back();
      }
    },
    setDatePickerDates: function(startDate, endDate) {
      var datePicker = $('input.date-picker').data('daterangepicker');
      datePicker.setStartDate(startDate);
      datePicker.setEndDate(endDate);
    }
  };

  var onDatePick = function(startDate, endDate, predefinedDatePeriod) {
    var selectedMetrics = selectMetricsForDateRange(startDate, endDate);
    var periodLabels = generateXAxisDateLabels(startDate, endDate);
    _(charts).map(function(chart) {
        updateChart(chart, selectedMetrics, periodLabels);
    });
    marchexCallTable.startDate = startDate;
    marchexCallTable.endDate = endDate;
    urlManager.pushNewState(startDate, endDate);
  };

  var initializer = {
    startDate: moment().startOf('month'),
    endDate: moment(),
    init: function() {
      urlManager.initialParse();
      marchexCallTable.startDate = this.startDate;
      marchexCallTable.endDate = this.endDate;
      onDatePick(initializer.startDate, initializer.endDate);
    }
  };

  // Make the back button work
  $(window).bind('popstate', function(event) { urlManager.popOldState(); });

  $('input.date-picker').daterangepicker({
    locale: {
      format: 'MMM D, YYYY'
    },
    startDate: initializer.startDate,
    endDate: initializer.endDate,
    minDate: moment().subtract(1, 'years'),
    maxDate: moment(),
    opens: 'left',
    ranges: {
      'Today':          [ moment(), moment() ],

      'Week to date':   [ moment().startOf('week'), moment() ],

      'Last week':      [ moment().subtract(1, 'week').startOf('week'),
                          moment().startOf('week').subtract(1, 'day') ],

      'Month to date':  [ moment().startOf('month'), moment() ],

      'Last month':     [ moment().subtract(1, 'month').startOf('month'),
                          moment().startOf('month').subtract(1, 'day') ],

      'Last 30 days':   [ moment().subtract(30, 'days'),
                          moment().subtract(1, 'day') ],

      'Year to date':   [ moment().startOf('year'), moment() ]
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
      labels: generateXAxisDateLabels(initializer.startDate, initializer.endDate),
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
            fontColor: 'rgba(0,0,0,.4)'
          }
        }],
        yAxes: [{
          type: 'linear',
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

  var funnelDefaults = $.extend(true, {}, lineDefaults, {
    options: {
      scales: {
        xAxes: [{
          ticks: {
            userCallback: function(value, index, values) {
              if (values.length > 25 && values.length < 33) {
                if ((index + 1) % 2) {
                  return value;
                } else {
                  // return nothing
                }
              } else {
                return value;
              }
            }
          }
        }]
      }
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
        mode: 'label',
        caretSize: 10
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
      var $summaryMetrics = $('.leads-widget .chart-summary-metric');
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
            return data.datasets[0].label + ': $' + tooltipItem.yLabel.toFixed(2);
          }
        }
      },
      scales: {
        yAxes: [{
          ticks: {
            userCallback: function(value, index, values) {
              return '$' + value;
            }
          }
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var cost = sum(this.data.datasets[0].data);
      var leads = sum(dateRangeMetrics.conversions);
      var costPerLead = cost / leads;
      var $summaryMetrics = $('.cost-widget .chart-summary-metric');
      $($summaryMetrics[0]).text('$' + cost.toFixed(2));
      $($summaryMetrics[1]).text('$' + costPerLead.toFixed(2));
    },
    metricsLabels: 'cost'
  });

  var impressionsChart = createChart('.impressions-chart', funnelDefaults, {
    data: {
      datasets: [
        {
          label: 'Impressions',
          data: []
        }
      ]
    },
    options: {
      scales: {
        yAxes: [{
          ticks: {
            userCallback: function(value, index, values) {
              return ( value / 1000 ) + 'k';
            }
          }
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      var impressions = sum(this.data.datasets[0].data);
      $('.impressions-widget .chart-summary-metric').text(impressions);
    },
    metricsLabels: 'impressions'
  });

  var clickThroughRateChart = createChart('.click-through-rate-chart', funnelDefaults, {
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
            return data.datasets[0].label + ': ' + tooltipItem.yLabel + '%';
          }
        }
      },
      scales: {
        yAxes: [{
          ticks: {
            userCallback: function(value, index, values) {
              return value + '%';
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
        .text(clickThroughRate.toFixed(2) + '%');
    },
    metricsLabels: 'clickThroughRate'
  });

  var clicksChart = createChart('.clicks-chart', funnelDefaults, {
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

  var conversionRateChart = createChart('.conversion-rate-chart', funnelDefaults, {
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
            return data.datasets[0].label + ': ' + tooltipItem.yLabel + '%';
          }
        }
      },
      scales: {
        yAxes: [{
          ticks: {
            userCallback: function(value, index, values) {
              return value + '%';
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
        .text(conversionRate.toFixed(2) + '%');
    },
    metricsLabels: 'conversionRate'
  });

  var adwordsClicksChart = createChart('.adwords-clicks-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Clicks',
          data: []
        }
      ]
    },
    options: {
      scales: {
        yAxes: [{
          ticks: {
          }
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.adwords-clicks-widget .chart-summary-metric')
        .text(sum(dateRangeMetrics.adwordsClicks));
    },
    metricsLabels: 'adwordsClicks'
  });

  var adwordsCost = createChart('.adwords-cost-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.adwords-cost-widget .chart-summary-metric')
        .text('$' + sum(dateRangeMetrics.adwordsCost).toFixed(2));
    },
    metricsLabels: 'adwordsCost'
  });

  var adwordsImpressions = createChart('.adwords-impressions-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Impressions',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.adwords-impressions-widget .chart-summary-metric')
        .text(sum(dateRangeMetrics.adwordsImpressions));
    },
    metricsLabels: 'adwordsImpressions'
  });

  var adwordsConversions = createChart('.adwords-conversions-chart',
                                               sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Conversions',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.adwords-conversions-widget .chart-summary-metric')
        .text(sum(dateRangeMetrics.adwordsFormConversions));
    },
    metricsLabels: 'adwordsConversionRate'
  });

  var bingadsClicksChart = createChart('.bingads-clicks-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Clicks',
          data: []
        }
      ]
    },
    options: {
      scales: {
        yAxes: [{
          ticks: {
          }
        }]
      }
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.bingads-clicks-widget .chart-summary-metric')
        .text(sum(dateRangeMetrics.bingadsClicks));
    },
    metricsLabels: 'bingadsClicks'
  });

  var bingadsCost = createChart('.bingads-cost-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Cost',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.bingads-cost-widget .chart-summary-metric')
        .text('$' + sum(dateRangeMetrics.bingadsCost).toFixed(2));
    },
    metricsLabels: 'bingadsCost'
  });

  var bingadsImpressions = createChart('.bingads-impressions-chart', sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Impressions',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.bingads-impressions-widget .chart-summary-metric')
        .text(sum(dateRangeMetrics.bingadsImpressions));
    },
    metricsLabels: 'bingadsImpressions'
  });

  var bingadsConversions = createChart('.bingads-conversions-chart',
                                               sparkLineDefaults, {
    data: {
      datasets: [
        {
          label: 'Conversions',
          data: []
        }
      ]
    },
    updateSummaryMetrics: function(dateRangeMetrics) {
      $('.bingads-conversions-widget .chart-summary-metric')
        .text(sum(dateRangeMetrics.bingadsFormConversions));
    },
    metricsLabels: 'bingadsConversionRate'
  });

  // -- END CHARTS SETUP

  initializer.init();

}());
