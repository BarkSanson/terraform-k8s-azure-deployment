/**
 * @author Martín Ignacio Rizzo
 * @author Pere Joan Vives Morey
 */


const MAX_RESULTS = 500;
const QUERY = 'all:deep+AND+all:learning';
const AUTHOR_NUMBER_URL = `http://export.arxiv.org/api/query?search_query=${QUERY}&start=0&max_results=${MAX_RESULTS}`;
const PASSENGER_NUMBER_URL = 'http://localhost:3000/flights/count';
const JUGADORES_URL = 'http://localhost:3000/jugadores';

$(document).ready(() => {
    $.get(AUTHOR_NUMBER_URL, processAuthorNumber);
    $.get(PASSENGER_NUMBER_URL, processPassengerNumber);
    $.get(JUGADORES_URL, processJugador);
});

const processAuthorNumber = (data, _) => {
        const xmlData = $(data);
        const entries = xmlData.find('entry');

        const author_count_map = {};

        entries.each((_, entry) => {
            const authors = $(entry).find('author').map((_, author) => {
                return $(author).find('name').text();
            }).get();
            const author_count = authors.length;

            if (author_count_map[author_count] === undefined) {
                author_count_map[author_count] = 1;
            } else {
                author_count_map[author_count] += 1;
            }
        }); 

        $('#spinner').remove();
        
        Highcharts.chart('author-count', {
            chart: {
                type: 'column'
            },
            title: {
                text: `Número de autores por paper más comunes en ${MAX_RESULTS} papers de arXiv sobre Deep Learning`
            },
            subtitle: {
                text: `Fuente: <a href="https://arxiv.org/">arXiv.org</a>`
            },
            xAxis: {
                title: {
                    text: 'Número de autores'
                },
                accessibility: {
                    description: 'Número de autores'
                },
                categories: Object.keys(author_count_map)
            },
            yAxis: {
                title: {
                    text: 'Número de papers'
                },
                accessibility: {
                    description: 'Número de papers'
                }
            },
            plotOptions: {
                column: {
                    dataLabels: {
                        enabled: true,
                        format: "{y}"
                    }
                }
            },
            series: [
                {
                    name: 'Número de papers',
                    data: Object.values(author_count_map)
                }
            ]
        });

};

const processPassengerNumber = (data, _) => {
    // Group daya by year
    const dataByYear = Object.groupBy(data, ({ year }) => {
        return year;
    });

    // Order data by month
    Object.keys(dataByYear).forEach((year) => {
        dataByYear[year] = dataByYear[year].sort((a, b) => {
            return a.month - b.month;
        });
    });

    const data2022 = dataByYear['2022'].map(({ passengers }) => parseInt(passengers));
    const data2021 = dataByYear['2021'].map(({ passengers }) => parseInt(passengers));
    const data2020 = dataByYear['2020'].map(({ passengers }) => parseInt(passengers));

    const categories = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
                        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    Highcharts.chart('passenger-count', {
        chart: {
            type: 'spline'
        },
        accessibility: {
            point: {
                valueDescriptionFormat: '{index}. {point.category}: {point.y}.'
            }
        },
        title: {
            text: "Número de pasajeros por mes durante 2020, 2021 y 2022"
        },
        xAxis: {
            categories,
            crosshair: true
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Número de pasajeros'
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:10px">Número de pasajeros en {point.key}</span><table>',
        },
        series: [
            {
                name: '2020',
                data: data2020 
            },
            {
                name: '2021',
                data: data2021
            },
            {
                name: '2022',
                data: data2022
            }
        ]
    });
    
};

const processJugador = (data,_) => {

    const nacionalidad = [];
    data.forEach(item =>{
        nacionalidad.push(item.nacionalidad);
    });

  

    const d8 = [];
    const d9 = [];
    const d10 = [];

    data.forEach(item => {
        d8.push(item.d8);
        d9.push(item.d9);
        d10.push(item.d10);
    });
    
    Highcharts.chart('jugadors', {
        chart: {
            type: 'bar'
        },
        title: {
            text: 'Número de Jugadores en intervalos de Medias'
        },
        // subtitle: {
        //     text: 'Source: <a ' +
        //         'href="https://en.wikipedia.org/wiki/List_of_continents_and_continental_subregions_by_population"' +
        //         'target="_blank">Wikipedia.org</a>',
        //     align: 'left'
        // },
        xAxis: {
            categories: nacionalidad,
            title: {
                text: 'Nacionalidades'
            },
            gridLineWidth: 1,
            lineWidth: 0
        },
        yAxis: {
            min: 0,
            labels: {
                overflow: 'justify'
            },
            title: {
                text: 'Número de Jugadores'
            },
            gridLineWidth: 0
        },
        // tooltip: {
        //     valueSuffix: ' millions'
        // },
        plotOptions: {
            bar: {
                borderRadius: '50%',
                dataLabels: {
                    enabled: true
                },
                groupPadding: 0.1
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'top',
            x: -40,
            y: 80,
            floating: true,
            borderWidth: 1,
            backgroundColor:
                Highcharts.defaultOptions.legend.backgroundColor || '#FFFFFF',
            shadow: true
        },
        credits: {
            enabled: false
        },
        series: [{
            name: 'Media entre 70 i 80',
            data: d8
        }, {
            name: 'Media entre 80 i 90',
            data: d9
        }, {
            name: 'Media entre 90 i 100',
            data: d10
        }]
    });
    
    
};