;(function() { $(document).ready(function() {

  // Sorts the Marchex table by the most recent call (5th column)
  $("[data-sort=table]").tablesorter({
    sortList: [[4,1]]
  });

  var $charts = $('.dashboard-chart');

  var create_chart = function(selector, defaults, configuration) {
    return new Chart(
      $charts.filter(selector),
      $.extend(true, {}, defaults, configuration)
    );
  };

  var periodLabels = ['April 28', 'April 29', 'April 30', 'May 1', 'May 2', 'May 3',
               'May 4', 'May 5', 'May 6', 'May 7', 'May 8', 'May 9', 'May 10',
               'May 11', 'May 12', 'May 13', 'May 14', 'May 15', 'May 16',
               'May 17', 'May 18', 'May 19', 'May 20', 'May 21', 'May 22',
               'May 23', 'May 24', 'May 25', 'May 26', 'May 27', 'May 28'];

  var chart_defaults = {
    data: {
      labels: periodLabels,
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
            maxRotation: 0,
            userCallback: function(value, index, values) {
              var calculated_value = (index + 1) % 3 ? '' : value;
              return calculated_value;
            }
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

  var line_defaults = $.extend(true, {}, chart_defaults, {
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

  var sparkline_defaults = $.extend(true, {}, chart_defaults, {
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

  var leads_chart = create_chart('.leads-chart', chart_defaults, {
    type: 'bar',
    data: {
      datasets: [
        {
          label: 'Calls',
          backgroundColor: '#1ca8dd',
          // Need this, otherwise something is changing the color on hover
          hoverBackgroundColor: '#1ca8dd',
          data: [ 0, 1, 1, 0, 1, 3, 0, 0, 2, 0,
                  1, 1, 0, 0, 1, 2, 1, 0, 0, 0,
                  1, 3, 0, 0, 0, 1, 2, 1, 0, 2, 1 ]
        },
        {
          label: 'Forms',
          backgroundColor: '#E64759',
          // Need this, otherwise something is changing the color on hover
          hoverBackgroundColor: '#E64759',
          data: [ 1, 1, 2, 2, 0, 1, 0, 2, 2, 1,
                  0, 0, 0, 1, 0, 3, 1, 0, 1, 0,
                  3, 1, 0, 1, 1, 0, 0, 2, 1, 0, 0 ]
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
    }
  });

  var cost_chart = create_chart('.cost-chart', line_defaults, {
    data: {
      datasets: [
        {
          label: 'Cost',
          pointRadius: 3,
          pointHoverRadius: 7,
          data: [ 65, 89, 43, 91, 67, 150, 120, 90,
                  73, 105, 80, 59, 78, 65, 94, 67,
                  91, 113, 74, 56, 93, 94, 56, 108,
                  99, 103, 63, 90, 64, 58, 41.32 ]
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
            userCallback: function(value, index, values) {
              return "$" + value;
            }
          }
        }]
      }
    }
  });

  var impressions_chart = create_chart('.impressions-chart', line_defaults, {
    data: {
      datasets: [
        {
          label: 'Impressions',
          data: [ 271, 311, 245, 290, 211, 302,
                  285, 228, 294, 236, 310, 294,
                  294, 236, 310, 221, 289, 253,
                  239, 273, 342, 352, 209, 274,
                  272, 235, 377, 266, 203, 283, 306 ]
        }
      ]
    }
  });

  var click_through_rate_chart = create_chart('.click-through-rate-chart', line_defaults, {
    data: {
      datasets: [
        {
          label: 'Click Through Rate',
          data: [ 5.9, 5.6, 5.4, 5.5, 6.1, 5.2,
                  4.9, 4.7, 5.7, 5.6, 5.8, 5.1,
                  5.4, 5.23, 5.67, 5.82, 5.35, 5.1,
                  5.2, 4.95, 5.36, 5.4, 5.6, 5.2,
                  5.17, 5.12, 5.19, 5.34, 5.39, 5.6, 5.1 ]
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
    }
  });

  var clicks_chart = create_chart('.clicks-chart', line_defaults, {
    data: {
      datasets: [
        {
          label: 'Clicks',
          data: [ 9, 11, 16, 14, 21, 15,
                  16, 23, 14, 23, 20, 12,
                  15, 14, 14, 13, 16, 14,
                  18, 20, 10, 13, 13, 18,
                  10, 15, 14, 17, 15, 7, 8 ]
        }
      ]
    }
  });

  var conversion_rate_chart = create_chart('.conversion-rate-chart', line_defaults, {
    data: {
      datasets: [
        {
          label: 'Conversion Rate',
          data: [ 11, 10, 11, 9, 11, 12,
                  11, 12, 13, 12, 11, 12,
                  9, 8, 8, 12, 11, 13,
                  13, 12, 16, 11, 5, 13,
                  11, 10, 9, 10, 10, 13, 17 ]
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
    }
  });

  var google_ad_position_chart = create_chart('.google-ad-position-chart', sparkline_defaults, {
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

  var google_cpc_chart = create_chart('.google-cpc-chart', sparkline_defaults, {
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

  var google_conversion_rate_chart = create_chart('.google-conversion-rate-chart',
                                                  sparkline_defaults, {
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

  var google_ctr_chart = create_chart('.google-ctr-chart', sparkline_defaults, {
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

  var bing_ad_position_chart = create_chart('.bing-ad-position-chart', sparkline_defaults, {
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

  var bing_cpc_chart = create_chart('.bing-cpc-chart', sparkline_defaults, {
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

  var bing_conversion_rate_chart = create_chart('.bing-conversion-rate-chart',
                                                  sparkline_defaults, {
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

  var bing_ctr_chart = create_chart('.bing-ctr-chart', sparkline_defaults, {
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
})}());
