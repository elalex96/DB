-- =============================================
-- Author:		<Author,,Name>
-- Create date: <14,Dic,2016>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGrafica]  
	-- Add the parameters for the stored procedure here

	@ID_Grafica int,
	@Contenedor varchar(max),
	@Idioma int,
	@Fecha_Inicio datetime,
	@Fecha_Fin datetime
	---@idioma int 1 Español, 2 Ingles

AS
BEGIN
	 
SET NOCOUNT ON;
 
declare @Script varchar(max)		= '<script type="text/javascript">' 
declare @SerieData varchar(max)		= '[]'
declare @TipoGraficaBD varchar(max) = (SELECT Tipo 
									   FROM DG_TipoGrafica AS TG, DG_Grafica AS G 
									   WHERE TG.Id_TipoGrafica=G.id_TipoGrafica AND G.Id_Grafica=@ID_Grafica)
declare @Titulo varchar(max)		= (SELECT CASE @IDIOMA WHEN 1 THEN REPLACE(REPLACE(REPLACE(Titulo,CHAR(9),''),CHAR(10),''),CHAR(13),'') ELSE REPLACE(REPLACE(REPLACE(Title,CHAR(9),''),CHAR(10),''),CHAR(13),'') END 
									   FROM DG_Grafica 
									   WHERE Id_Grafica =@ID_Grafica)
declare	@Subtitulo varchar(max)		= (SELECT CASE @IDIOMA WHEN 1 THEN REPLACE(REPLACE(REPLACE(Subtitulo,CHAR(9),''),CHAR(10),''),CHAR(13),'') ELSE REPLACE(REPLACE(REPLACE(Subtitle,CHAR(9),''),CHAR(10),''),CHAR(13),'') END
									   FROM DG_Grafica 
									   WHERE Id_Grafica = @ID_Grafica)
declare	@TituloX varchar(max)		= (SELECT CASE @Idioma WHEN 1 THEN REPLACE(REPLACE(REPLACE(Titulo_xAxis,CHAR(9),''),CHAR(10),''),CHAR(13),'') ELSE REPLACE(REPLACE(REPLACE(Title_xAxis,CHAR(9),''),CHAR(10),''),CHAR(13),'')  END  
									   FROM DG_Grafica 
									   WHERE Id_Grafica = @ID_Grafica)
declare	@TituloY varchar(max)		= (SELECT CASE @Idioma WHEN 1 THEN REPLACE(REPLACE(REPLACE(Titulo_yAxis,CHAR(9),''),CHAR(10),''),CHAR(13),'')  ELSE REPLACE(REPLACE(REPLACE(Title_yAxis,CHAR(9),''),CHAR(10),''),CHAR(13),'')  END  
									   FROM DG_Grafica 
									   WHERE Id_Grafica = @ID_Grafica)
declare @Categorias varchar(max)	= (SELECT CASE @Idioma WHEN 1 THEN REPLACE(REPLACE(REPLACE(C.categorias,CHAR(9),''),CHAR(10),''),CHAR(13),'') ELSE REPLACE(REPLACE(REPLACE(C.Categories,CHAR(9),''),CHAR(10),''),CHAR(13),'') END 
									   FROM DG_Categorias AS C 
									   inner join DG_CategoriasGrafica AS CG ON CG.ID_Categoria=C.ID_Categoria 
									   WHERE Id_Grafica = @ID_Grafica)

declare	@viewDistance varchar(max) 
declare @depth varchar(max)
declare @datos varchar(max)

exec   spGraficaDatos @ID_Grafica, @Fecha_Inicio, @Fecha_Fin,@datos output 

IF  @TipoGraficaBD = 'column3D_SG'
BEGIN
	select @viewDistance = (select ViewDistance from DG_Grafica AS G where Id_Grafica = @ID_Grafica)
	select @depth = (select G.Depth from DG_Grafica as G where Id_Grafica = @ID_Grafica)
END 


 
	SELECT CASE  @TipoGraficaBD
		WHEN  'line'  THEN  --1

					 CONCAT( @Script ,  ' Highcharts.chart("'+@Contenedor+'", { '
					+' chart: {' 
					+           'type: "'+@TipoGraficaBD+'" 
					             }, 
					             title: { '  
					+                   '   text: "'+@Titulo+'"
					                 }, 
									tooltip: {
									valueSuffix: ""
								},
					                  subtitle: { 
					                     text: "'+@Subtitulo+'" 
					                 }, 
					                xAxis: { 
					                      categories: ['+ @Categorias +']
					                  }, 
					                   yAxis: { 
					                       title: { 
					                         text: "'+@TituloX+'" 
					                  } 
									,plotLines: [{
										value: 0,
										width: 1,
										color: "#808080"
									}]
					                  },
									 credits: {
										  enabled: false
									  }, 
					                  series:['+  @datos +'] 
								   }); '  
					+   '</script>' ) +''


		WHEN  'bar' THEN  --2

					 CONCAT( @Script ,  ' Highcharts.chart("'+@Contenedor+'", { '
					+' chart: {' 
					+           'type: "'+@TipoGraficaBD+'"' 
					+         '    },' 
					+         '    title: {'  
					+                   '   text: "'+@Titulo+'"' 
					+                ' },' 
					+                 ' subtitle: {' 
					+                  '   text: "'+@Subtitulo+'"' 
					+               '  },' 
					+              '  xAxis: {' 
					+                      'categories: ['+ @Categorias +']' 
					+                '  },' 
					+                '   yAxis: {' 
					+                      ' title: {' 
					+                         ' text: "'+@TituloX+'"' 
					+                 '      }' 
					+                '  },' 
					+               '    plotOptions: { ' 
					+                     '  line: {' 
					+                          ' dataLabels: {' 
					+                      '         enabled: true' 
					+                     '     },' 
					+                      '   enableMouseTracking: false' 
					+                   '    }' 
					+                 '  },' 
					+					' credits: {
											  enabled: false
										  },'
					+                   'series:['+@datos +']'
										  
					+           '   }); '  
					+   '</script>' ) +''

		WHEN  'column' THEN   --3
			CONCAT( @Script ,  ' Highcharts.chart("'+@Contenedor+'", { '
			+' chart: {' 
			+           'type: "'+@TipoGraficaBD+'" 
			             }, 
			             title: {'  
			+                   '   text: "'+@Titulo+'" 
			                 }, 
			                  subtitle: { 
			                     text: "'+@Subtitulo+'"' 
			+              '  }, 
			                xAxis: { 
			                      categories:['+ @Categorias +']
			                  }, 
			                   yAxis: { 
			                       title: { 
			                          text: "'+@TituloX+'" 
			                       } 
			                  }, 
			                   plotOptions: {  
			                       line: { 
			                           dataLabels: { 
			                               enabled: true 
			                          }, 
			                         enableMouseTracking: false 
			                       } 
			                   }, 
								 credits: {
										enabled: false
									},
			                   series:['+@datos +']
								  
			              }) '  
			+   '</script>' ) +''

		WHEN 'area'   THEN --4

			CONCAT( @Script ,  ' Highcharts.chart("'+@Contenedor+'", { '
				+' chart: {' 
				+         'type: "'+@TipoGraficaBD+'" 
					            }, 
					            title: {' 
				+                   'text: '''+@Titulo+'''
					                }, 
					                subtitle: {
					                    text: "'+@Subtitulo+'"
					                }, 
					            xAxis: {' 
				+                      'categories:['+ @Categorias +']
					                },
					                yAxis: { 
					                    title: { 
					                        text: "'+@TituloX+'" 
					                    } 
					                }, 
					                plotOptions: {  
					                    line: { 
					                        dataLabels: { 
					                            enabled: true 
					                        }, 
					                        enableMouseTracking: false 
					                    } 
					                }, 
										credits: {
											enabled: false
										},
					                series:['+@datos +']
									  
					            });'   
				+   '</script>' ) +''

		WHEN 'column3D' THEN --6

			CONCAT( @Script ,  'var '+@Contenedor+'= Highcharts.chart("'+@Contenedor+'", {'
				+'chart: {'
				+    'type: "column",
						options3d: {
							enabled: true,
							alpha: 10,
							beta: 25,
							depth: 70
						}
					},
					title: {
						text: "'+@Titulo+'"'
				+'},
					subtitle: {
						text: "'+@Subtitulo+'"
					},
					plotOptions: {
						column: {
							depth: 25
						}
					},
					xAxis: {
						categories: ['+ @Categorias +']
					},
					yAxis: {
						title: {
							text: "'+@TituloY+'"
						}
					},
					credits: {
						enabled: false
					},
					series: ['+@datos+']
				});'  
			+   '</script>' ) +''

		WHEN 'pie' THEN --5
					 	
			CONCAT( @Script ,  'Highcharts.chart("'+@Contenedor+'", {
				chart: {
					type: "pie",
					options3d: {
						enabled: true,
						alpha: 45,
						beta: 0
					}
				}
				,
				title: {
					text: "'+@Titulo+'"
				},
				tooltip: {
					pointFormat: "{series.name}: <b>{point.percentage:.1f}%</b>"
				},
				plotOptions: {
					pie: {
						allowPointSelect: true,
						cursor: "pointer",
						depth: 35,
						dataLabels: {
							enabled: true,
							format: "{point.name}"
						}
					}
				},
					credits: {
					enabled: false
				},
				series: [{
			        type: "pie",
			        name: "'+@Titulo+'",
			        data: ['+@datos+']
					}]
			});'  
					
			+   '</script>' ) +''
				
	WHEN 'column3D_SG' THEN  --7

		CONCAT(@Script, 'Highcharts.chart("'+@Contenedor+'", {
				chart: {
					type: "column",
					options3d: {
						enabled: true,
                        alpha: 5,
                        beta: 55,
                        viewDistance: '+@viewDistance+',
                        depth: '+@depth+'
					}
				},

				title: {
					text: "'+@Titulo+'"
				},

				xAxis: {
					categories: ['+@Categorias+']
				},

				yAxis: {
					allowDecimals: false,
					min: 0,
					title: {
						text: "'+@TituloY+'"
					}
				},

				  tooltip: {
					headerFormat: "<b>{point.key}</b><br>",
					 pointFormat: ''<span style="color:{series.color}">\u25CF</span> {series.name}: {point.y} / {point.stackTotal}''
				},
				credits: {
					enabled: false
				},
				plotOptions: {
					column: {
						stacking: "normal",
						depth: 40
					}
				},

				series: ['+@datos+']
			});'  +   '</script>' ) +''

	WHEN 'column_SP' THEN --8

			CONCAT(@Script, ' Highcharts.chart("'+@Contenedor+'", {
			chart: {
				type: "column"
			},
			title: {
				text: "'+@Titulo+'"
			},
			xAxis: {
				categories: ["2013", "2014", "2015", "2016"]
			},
			yAxis: {
				min: 0,
				title: {
					text: "'+@TituloY+'"
				}
			},
			tooltip: {
				pointFormat: ''<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>'',
				shared: true
			},
			credits: {
				enabled: false
			},
			plotOptions: {
				column: {
					stacking: "percent"
				}
			},
			series: ['+@datos+']
		});'  +   '</script>' ) +''

	WHEN 'colum_line_pie' THEN --9

			CONCAT(@Script, 'Highcharts.chart("'+@Contenedor+'", {
				title: {
					text: "'+@Titulo+'"
				},
				xAxis: {
					categories: ['+@Categorias+']
				},
				credits: {
					enabled: false
				},
				series: ['+@datos+']
			});'  +   '</script>' ) +''

	ELSE 'No se encontro este tipo de grafica'
	END as Texto 

END



