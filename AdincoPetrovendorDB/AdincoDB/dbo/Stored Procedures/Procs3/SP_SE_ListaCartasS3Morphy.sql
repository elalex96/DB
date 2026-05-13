CREATE PROCEDURE [dbo].[SP_SE_ListaCartasS3Morphy]
-- Add the parameters for the stored procedure here  
-- [SP_SE_ListaCartasS3Morphy] 3,1,'2018-01-01','2020-03-01'
@IdContrato INT, 
@IdUsuario  INT, 
--@IdPresupuesto INT, 
@FInicio    DATE, 
@FFin       DATE
AS
     BEGIN

	 --RFC Contrato
	 DECLARE @RFC VARCHAR(50)
	 SELECT @RFC = CC.RFC FROM Adinco.dbo.CO_Contrato C 
	 JOIN Adinco.dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista
	 WHERE C.IdContrato = @IdContrato

	 --
         CREATE TABLE #ICNMurphy
         (Identificador   NVARCHAR(MAX), 
          Carpeta         NVARCHAR(MAX), 
          Ruta            NVARCHAR(MAX), 
          Cubeta          NVARCHAR(MAX), 
          NombreDocumento NVARCHAR(MAX), 
          IdFactura       INT, 
          UUID            NVARCHAR(MAX), 
          IdContrato      INT
         );
         INSERT INTO #ICNMurphy
         (Identificador, 
          Carpeta, 
          Ruta, 
          Cubeta, 
          NombreDocumento, 
          IdFactura, 
          UUID, 
          IdContrato
         )
                SELECT DISTINCT 
                       S3.Identificador, 
                       S3.Carpeta, 
                       CONCAT(S3.Carpeta, S3.Identificador) AS Ruta, 
                       'petrovendor-pr' AS Cubeta, 
                       S3.NombreDocumento AS NombreDocumento, 
                       F.IdFactura, 
                       F.UUID, 
                       F.IdContrato--,
					   --C.NumeroContrato--select *
                FROM Petrovendor.dbo.MPY_MM_AceptacionPedidoDetalle APD
                     JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
                     JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                     JOIN Petrovendor.dbo.MPY_MM_PCN_ValoresPesos VP ON VP.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
                     JOIN Petrovendor.dbo.MPY_MM_AceptacionCartaPCN AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                     JOIN Petrovendor.dbo.MM_BS_Actividad A ON VP.IdCatalogoHidrocarburos = A.IdActividad
                     JOIN Petrovendor.dbo.FI_Factura F ON AF.IdFactura = F.IdFactura
                     JOIN Petrovendor.dbo.CN_ClasificacionContenidoSH CN ON APD.ClasificacionCN = CN.IdClasificacionSH
                     JOIN Petrovendor.dbo.S_Documento_S3 S3 ON AC.IdDocumento = S3.IdDocumento
                     JOIN Petrovendor.dbo.S_Proveedor PE ON F.Emisor = PE.RFC
                     JOIN Petrovendor.dbo.S_Proveedor PR ON F.Receptor = PR.RFC
                     JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON CAST(APD.Creado AS DATE) = TCD.Fecha
                                                                AND TCD.IdMoneda <> F.IdMoneda
                                                                AND TCD.IdMoneda <> 10000
					 JOIN Adinco.dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
					 JOIN Adinco.dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista
                WHERE(CAST(F.Fecha AS DATE) >= @FInicio
                      AND CAST(F.Fecha AS DATE) <= EOMONTH(@FFin))
                     AND F.IdContrato = @IdContrato
                     AND APD.PCN <> 0
					 --AND F.Receptor = @RFC
					 --AND F.Receptor = 'MSU150922EYA'--murphy
					 --AND F.Receptor = 'DEP180824FS8'--dorado
         SELECT Identificador, 
                Carpeta, 
                Ruta, 
                Cubeta, 
                NombreDocumento, 
                IdFactura, 
                UUID, 
                IdContrato
         FROM #ICNMurphy;
     END;