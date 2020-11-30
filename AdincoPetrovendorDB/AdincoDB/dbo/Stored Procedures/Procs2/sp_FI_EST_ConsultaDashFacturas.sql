-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_EST_ConsultaDashFacturas]
-- 10003,  '2016-01-01', '2016-12-12'
-- Add the parameters for the stored procedure here
@IdContrato INT
--@PInicial   NVARCHAR(50),
--@PFinal     NVARCHAR(50)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

		 DECLARE @GRAFICA NVARCHAR(MAX)
		 DECLARE @DATOS NVARCHAR(MAX)

		  --SELECT Folio + ' - ' +  Emisor ,         
    --            SubTotal,
    --            MontoConIva
    --      FROM FI_Factura F
    --          JOIN PV_Subcontratista SE ON F.IdSubcontratista = SE.IdSubcontratista
    --          JOIN CO_Contrato C ON C.IdContrato = 3
    --          JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
    --      WHERE F.IdContrato = 3
             ---  AND F.Fecha BETWEEN @PInicial AND @PFinal
			  ---- and isnull(F.ProcesadoSIPAC, 'false') = 'false'
			  ---- and rtrim(ArchivoXML ) <>''




		SET  @DATOS =(
		SELECT 
	    '['+
		(SELECT STUFF((
						SELECT '[''',Folio + ' - ' + Emisor   +''',' + CAST([SubTotal] AS VARCHAR(MAX)) + '],'
						FROM [dbo].[FI_Factura] AS F 
						JOIN PV_Subcontratista SE ON F.IdSubcontratista = SE.IdSubcontratista
				        JOIN CO_Contrato C ON C.IdContrato = @IdContrato
					    JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
						WHERE F.IdContrato = @IdContrato 
						and isnull(F.ProcesadoSIPAC, 'false') = 'false'
					    and rtrim(ArchivoXML ) <>''
						
						FOR XML PATH('')
					), 1, 1, '') ) 
		)
		SET @DATOS  = SUBSTRING (@DATOS, 1, Len(@DATOS) - 1 )



		SET @GRAFICA = '<script type="text/javascript">     Highcharts.chart("facturas", {
            chart: {
                type: "column"
            },
            title: {
                text: "Facturas - Subtotales"
            },
            subtitle: {
                text: "Periodo - Periodo"
            },
            xAxis: {
                type: "category",
                labels: {
                    rotation: -45,
                    style: {
                        fontSize: "13px",
                        fontFamily: "Verdana, sans-serif"
                    }
                }
            },
            yAxis: {
                min: 0,
                title: {
                    text: "SubTotal"
                }
            },
            legend: {
                enabled: false
            },
            tooltip: {
                pointFormat: "SubTotal: <b>$ {point.y:.1f} </b>"
            },
            series: [{
                name: "Folio Factura",
                data: [
                    '+@DATOS+'
                ],
                dataLabels: {
                    enabled: true,
                    rotation: -90,
                    color: "#FFFFFF",
                    align: "right",
                    format: "{point.y:.2f}", // one decimal
                    y: 10, // 10 pixels down from the top
                    style: {
                        fontSize: "13px",
                        fontFamily: "Verdana, sans-serif"
                    }
                },
                
            }]
        });
		
    </script>'




		
		SELECT @GRAFICA
     END;