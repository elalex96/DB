CREATE PROCEDURE [dbo].[SP_FACTURAS_COMPROBANTESHIJO] 
	@IdFacturapadre INT
AS
BEGIN
	SET NOCOUNT ON;	
			SELECT 
				PC.IdPedimentoComprobante AS Identificador,
				CASE
					WHEN PC.CvTipoDocFacturacion = 2
					THEN 'Pedimento'
					ELSE 'Comprobante'
				END Tipo,
				PC.NumeroPedimento,	
				CP.Clave ClavePedimento,
				PC.FolioComprobante,
				PC.FechaPago,
				PC.Regimen,
				SUBSTRING(SI.RazonSocial, 0, 30) AS Importador,
				SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador, 
				PC.AduanaES,
				PCD.ClaseBienServicio, 
				SUBSTRING(MU.UMB, 0, 30) AS UnidadMedida, 
				PC.AcuseElectronico,
				PCD.DescripcionMercancia,
				TM.TipoMonedaCorto,
				SUM(CASE
						WHEN PCD.ImporteTotal IS NOT NULL
						THEN PCD.ImporteTotal
						ELSE PCD.PrecioUnitario
					END) AS 'PrecioUnitario', 
				PCD.Cantidad,
				ISNULL(PC.CuentaBancaria,'') CuentaBancaria,
				PC.NumFacturaC
			FROM FI_PedimentoComprobante PC
				INNER JOIN dbo.FI_RelacionPedimento RF 
					ON PC.CvTipoDocFacturacion IN (2,3) AND
					   RF.IdFacturaPadre = @IdFacturapadre AND 
					   PC.IdPedimentoComprobante = RF.IdPedimentoHijo
				LEFT JOIN dbo.FI_PedimentoComprobanteDetalle PCD 
					ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante				  
				LEFT JOIN dbo.PV_Subcontratista SI 
					ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
				LEFT JOIN dbo.PV_Subcontratista SE 
					ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
				INNER JOIN dbo.PV_TipoMoneda TM 
					ON PC.IdMoneda = TM.IdMoneda				
				LEFT JOIN dbo.AP_Usuario UC 
					ON PC.CreadoPor = UC.UsuarioID
				LEFT JOIN dbo.AP_Usuario UM 
					ON PC.ModificadoPor = UM.UsuarioID
				LEFT JOIN dbo.FI_Documento D 
					ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
				LEFT JOIN dbo.FI_ClavesPedimento CP 
					ON PC.ClavePedimento = CP.IdPedimento	
					LEFT JOIN dbo.PV_MM_MaterialUnidad MU 
					ON PCD.IdUnidadMedida = MU.IdUnidad
			GROUP BY 
				PC.IdPedimentoComprobante,	
				CASE
					WHEN PC.CvTipoDocFacturacion = 2
					THEN 'Pedimento'
					ELSE 'Comprobante'
				END,
				PC.NumeroPedimento,	
				CP.Clave,
				PC.FolioComprobante,
				PC.FechaPago,
				PC.Regimen,
				SUBSTRING(SI.RazonSocial, 0, 30),
				SUBSTRING(SE.RazonSocial, 0, 30), 
				PC.AduanaES,
				PCD.ClaseBienServicio, 
				SUBSTRING(MU.UMB, 0, 30), 
				PC.AcuseElectronico,
				PCD.DescripcionMercancia,
				TM.TipoMonedaCorto,
				PCD.Cantidad,
				ISNULL(PC.CuentaBancaria,''),
				PC.NumFacturaC
			ORDER BY Identificador DESC;		
END;