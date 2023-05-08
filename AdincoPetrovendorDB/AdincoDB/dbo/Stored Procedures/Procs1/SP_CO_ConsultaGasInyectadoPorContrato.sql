create PROCEDURE [dbo].[SP_CO_ConsultaGasInyectadoPorContrato]
@IdContrato INT,
@IdUsuario INT,
@Language INT
AS
--Produccion de gas 
--Inyeccion de gas 
--Suma de produccion mas inyeccion 
BEGIN
-- EXEC sp_CO_ConsultaLineaPresupuestoMes_widget '1','2','1'

  SELECT 
 'Indicador de Gas Inyectado' AS 'Titulo',
 '' AS 'Subtitulo',
 UM.Abreviatura AS 'Titulo_yAxis',
 'Month' AS 'Titulo _xAxis',
 CONCAT(SUBSTRING(CAST(YEAR(PMS.idFecha) AS VARCHAR(4)), 3, 2), ' ', RIGHT('00'+CAST(MONTH(PMS.idFecha) AS VARCHAR(2)), 2), ' ', SUBSTRING(dbo.Fn_ObtenerNombreMes(@Language, MONTH(PMS.idFecha)), 0, 4)) AS 'Fecha',
 '3' AS 'CantidadSeries',
 UM.Abreviatura AS 'ValueSuffix',
 CONCAT('Produccón de ',PN.nombre )AS 'SerieName0',
 PMS.VolumenProgramado AS 'SerieValues0',
 'line' AS 'SerieType0',
 'gold' AS 'SerieColor0',


 'Inyección de Gas' AS 'SerieName1',
 PMS.VolumenProgramado  AS 'SerieValues1',
 'line' AS 'SerieType1',
 'blue' AS 'SerieColor1',

 'Produccón y Gas' AS 'SerieName2',
 COALESCE(PMS.VolumenProgramado,0)+COALESCE(PMS.VolumenProgramado,0) AS 'SerieValues2',
 'line' AS 'SerieType2',
 'red' AS 'SerieColor2',



 '' AS 'SerieName3',
 '' AS 'SerieValues3',
 'line' AS 'SerieType3',
 'green' AS 'SerieColor3',
 
 '' AS 'SerieName4',
 '' AS 'SerieValues4',
 'line' AS 'SerieType4',
 'blue' AS 'SerieColor4',

 '' AS 'SerieName5',
 '' AS 'SerieValues5',
 'line' AS 'SerieType5',
 'blue' AS 'SerieColor5',
 
 '' AS 'SerieName6',
 '' AS 'SerieValues6',
 'line' AS 'SerieType6',
 'blue' AS 'SerieColor6'
 FROM 
 dbo.PR_ProduccionMensualSipac AS PMS
 INNER JOIN  dbo.CO_ClasificacionProductoNominacion AS PN ON PN.ProductoNominacionID = PMS.idHidrocarburo
 INNER JOIN dbo.CO_UnidadMedida AS UM ON UM.idUnidadMedida = PMS.idUnidadMedida
 WHERE idHidrocarburo = 1000 --GAS
 AND PMS.idContrato = @IdContrato 

END
