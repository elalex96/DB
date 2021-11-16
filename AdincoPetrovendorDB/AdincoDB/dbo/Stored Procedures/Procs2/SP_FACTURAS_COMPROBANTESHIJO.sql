CREATE PROCEDURE [dbo].[SP_FACTURAS_COMPROBANTESHIJO] 
	@IdFacturapadre INT,
	@Tipo INT
AS
BEGIN
	SET NOCOUNT ON;
	IF(@Tipo = 2)
		BEGIN 
			SELECT 
				PC.IdPedimentoComprobante IdPedimento,	
				PC.NumeroPedimento,	
				CP.Clave ClavePedimento,
				PC.FolioComprobante,
				PC.FechaPago,
				PC.Regimen,
				SI.RazonSocial Importador,
				PC.AduanaES,
				SUBSTRING(SE.RazonSocial, 0, 30) Exportador,
				PC.AcuseElectronico,
				PCD.DescripcionMercancia,
				TM.TipoMonedaCorto,
				PCD.PrecioUnitario,
				PCD.Cantidad,
				CASE
					WHEN D.DocumentoByte IS NULL OR D.DocumentoByte LIKE 0x
						THEN 'NO CARGADO'
						ELSE 'Cargado'
					END  'Archivo',
				UC.Nombre CreadoPor,
				PC.CreadoEn,
				UM.Nombre ModificadoPor,
				PC.ModificadoEn,
				ISNULL(pc.CuentaBancaria,'') CuentaBancaria
			FROM FI_PedimentoComprobante PC
				INNER JOIN dbo.FI_RelacionPedimento RF 
					ON PC.CvTipoDocFacturacion IN (2) AND
					   RF.IdFacturaPadre = @IdFacturapadre AND 
					   PC.IdPedimentoComprobante = RF.IdPedimentoHijo
				INNER JOIN dbo.FI_PedimentoComprobanteDetalle PCD 
					ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante				  
				INNER JOIN dbo.PV_Subcontratista SE
					ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
				INNER JOIN dbo.PV_TipoMoneda TM 
					ON PC.IdMoneda = TM.IdMoneda
				LEFT JOIN dbo.PV_Subcontratista SI 
					ON PC.IdSubcontratistaImportador = SI.IdSubcontratista 
				LEFT JOIN dbo.AP_Usuario UC 
					ON PC.CreadoPor = UC.UsuarioID
				LEFT JOIN dbo.AP_Usuario UM 
					ON PC.ModificadoPor = UM.UsuarioID
				LEFT JOIN dbo.FI_Documento D 
					ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
				LEFT JOIN dbo.FI_ClavesPedimento CP 
					ON PC.ClavePedimento = CP.IdPedimento	
			ORDER BY IdPedimento DESC;
		END;
	ELSE
		BEGIN
			SELECT 
				PC.IdPedimentoComprobante AS IdComprobante, 
				PC.FolioComprobante, 
				PC.FechaPago, 
				SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador, 
				PCD.NumeroSerieMercancia, 
				PCD.ClaseBienServicio, 
				SUBSTRING(MU.UMB, 0, 30) AS UnidadMedida, 
				TM.TipoMonedaCorto,					
				SUM(CASE
						WHEN PCD.ImporteTotal IS NOT NULL
						THEN PCD.ImporteTotal
						ELSE PCD.PrecioUnitario
					END) AS 'PrecioUnitario', 
				PCD.Cantidad,  
				NULL AS 'ImporteTotal', 
				L.Nombre AS FormaDePago,
				CASE
					WHEN D.DocumentoByte IS NULL
							OR D.DocumentoByte LIKE 0x
					THEN 'NO CARGADO'
					ELSE 'Cargado'
				END AS 'Archivo', 
				UC.Nombre AS CreadoPor, 
				PC.CreadoEn, 
				UM.Nombre AS ModificadoPor, 
				PC.ModificadoEn, 
				PC.NumFacturaC,
				CASE
					WHEN ISNULL(PC.EsnotaCredito, 0) = 0
					THEN 'No'
					ELSE 'Si'
				END AS EsnotaCredito
			FROM FI_PedimentoComprobante AS PC
				 INNER JOIN dbo.FI_RelacionPedimento RF 
						ON PC.CvTipoDocFacturacion IN (3) AND
						   RF.IdFacturaPadre = @IdFacturapadre AND 
						   PC.IdPedimentoComprobante = RF.IdPedimentoHijo
				LEFT JOIN FI_PedimentoComprobanteDetalle AS PCD 
					ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
				LEFT JOIN dbo.PV_Subcontratista SI 
					ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
				LEFT JOIN dbo.PV_Subcontratista SE 
					ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
				LEFT JOIN dbo.PV_TipoMoneda TM 
					ON PC.IdMoneda = TM.IdMoneda
				LEFT JOIN dbo.AP_Usuario UC 
					ON PC.CreadoPor = UC.UsuarioID
				LEFT JOIN dbo.AP_Usuario UM 
					ON PC.ModificadoPor = UM.UsuarioID
				LEFT JOIN dbo.AP_Lista L 
					ON PC.IdFormaPago = L.IdClave AND 
					   IdGrupo = 10001
				LEFT JOIN dbo.PV_MM_MaterialUnidad MU 
					ON PCD.IdUnidadMedida = MU.IdUnidad
				LEFT JOIN dbo.FI_Documento D 
					ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
			 GROUP BY 
				PC.IdPedimentoComprobante, 
				PC.FolioComprobante, 
				PC.FechaPago, 
				SUBSTRING(SE.RazonSocial, 0, 30), 
				PCD.NumeroSerieMercancia, 
				PCD.ClaseBienServicio, 
				SUBSTRING(MU.UMB, 0, 30), 
				TM.TipoMonedaCorto, 
				PCD.Cantidad, 
				L.Nombre,
				CASE
					WHEN D.DocumentoByte IS NULL
						OR D.DocumentoByte LIKE 0x
					THEN 'NO CARGADO'
					ELSE 'Cargado'
				END, 
				UC.Nombre, 
				PC.CreadoEn, 
				UM.Nombre, 
				PC.ModificadoEn, 
				PC.NumFacturaC,
				CASE
					WHEN ISNULL(PC.EsnotaCredito, 0) = 0
					THEN 'No'
					ELSE 'Si'
				END
			 ORDER BY IdComprobante DESC;
		END;	
END;