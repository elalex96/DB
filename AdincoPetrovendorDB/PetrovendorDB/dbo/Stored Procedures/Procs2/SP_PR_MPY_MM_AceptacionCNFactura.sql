-- =============================================
-- Author:		Pedro Acuña
-- Update date: 13-06-2018
-- Description:	store para poblar los grid de la ventanilla unica
-- =============================================

CREATE procedure [dbo].[SP_PR_MPY_MM_AceptacionCNFactura]
	@IdProveedor NVARCHAR(50), 
	@Estatus INT
AS
	BEGIN
		SET NOCOUNT ON ;

		DECLARE @SAPVENDOR NVARCHAR(50) = (SELECT TOP 1 VendorIDSAP FROM Adinco.dbo.CO_SAPVendor WHERE TaxID = @IdProveedor);

		-- Insert statements for procedure here
		IF @Estatus = 0
			BEGIN
				SELECT		AP.IdAceptacionPedido, 
							AP.IdPedido ,
							ISNULL(CO.NombreContratista, AP.IdProveedor) AS Cliente ,
							APC.FechaEvaluacion AS FechaAperturaCarga ,
							'Sin Iniciar Aprobación' AS EstatusCarga
				FROM MPY_MM_AceptacionPedido AS AP
				LEFT JOIN	MPY_MM_AceptacionCartaPCN AS APC
					ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN	S_Proveedor AS PV
					ON PV.RFC = AP.IdProveedor AND PV.Activo = 1
				LEFT JOIN	MPY_MM_AceptacionFactura AS AF
					ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
					   AND	ISNULL ( AF.IdEstatusEliminado, 0 ) <> 1 ---> LA ACEPTACIÓN DE FACTURA NO DEBE ESTAR ELIMINADA PARA MOSTRARSE
				LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = AP.IdProveedor
				WHERE (AP.IdSubContratista = @IdProveedor or AP.IdSubContratista = @SAPVENDOR)
							AND APC.IdEstatus = 2
							AND APC.FechaEvaluacion IS NOT NULL
							AND ISNULL ( AF.IdEstatusEliminado, 0 ) <> 1	--> SI LA CARTA CONTENIDO ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA
				GROUP BY	AP.IdAceptacionPedido, AP.IdPedido, PV.RazonSocial, PV.RegimenCapital, APC.FechaEvaluacion, AP.IdProveedor,CO.NombreContratista
				ORDER BY	AP.IdAceptacionPedido DESC
			END

		IF @Estatus IN ( 1, 2, 3)
			BEGIN
				SELECT		AP.IdAceptacionPedido, 
							AP.IdPedido ,
							ISNULL(CO.NombreContratista,AP.IdProveedor) AS Cliente ,
							APC.FechaEvaluacion AS FechaAperturaCarga ,
							ISNULL(TVDF.TipoValidacion, 'Sin Iniciar Aprobación') AS EstatusCarga,
							AF.IdAceptacionFactura
				FROM MPY_MM_AceptacionPedido AS AP
				LEFT JOIN	MPY_MM_AceptacionCartaPCN AS APC
					ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN	MPY_MM_AceptacionFactura AS AF
					ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN	S_TipoValidacionDoc AS TVDF
					ON TVDF.IdTipoValidacionDoc = AF.IdEstatusXML
				LEFT JOIN	S_Proveedor AS PV
					ON PV.RFC = AP.IdProveedor AND PV.Activo = 1
				LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = AP.IdProveedor
				WHERE (AP.IdSubContratista = @IdProveedor or AP.IdSubContratista = @SAPVENDOR)
							AND AF.IdEstatusXML IS NULL
							AND APC.IdEstatus = 2
							AND ISNULL ( AF.IdEstatusEliminado, 0 ) <> 1	--> SI LA ACEPTACION DE FACTURA ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA	EN FILTRO, SE MUESTRA EN TODAS CON ESTATUS/INACTIVO
				GROUP BY	AP.IdAceptacionPedido, 
							AP.IdPedido, 
							PV.RazonSocial, 
							PV.RegimenCapital, 
							APC.FechaEvaluacion ,
							APC.IdEstatusEliminado, 
							AF.IdEstatusEliminado,
							AF.IdAceptacionFactura,
							TVDF.TipoValidacion,
							AP.IdProveedor,
							CO.NombreContratista
				ORDER BY	AP.IdAceptacionPedido DESC
			END 

		---APC.IdEstatus=2 EStatus Aprobado 

		IF @Estatus = 10 ---Todas las aceptaciones que requieren de una factura y estatus de aprobación
			BEGIN
				SELECT		AP.IdAceptacionPedido, 
							AP.IdPedido ,
							ISNULL(CO.NombreContratista,AP.IdProveedor) AS Cliente ,
							APC.FechaEvaluacion AS FechaAperturaCarga ,
							ISNULL(TVDF.TipoValidacion, 'Sin Iniciar Aprobación') AS EstatusCarga,
							AF.IdAceptacionFactura
				FROM MPY_MM_AceptacionPedido AS AP
				LEFT JOIN	MPY_MM_AceptacionCartaPCN AS APC
					ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN	MPY_MM_AceptacionFactura AS AF
					ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN	S_TipoValidacionDoc AS TVDF
					ON TVDF.IdTipoValidacionDoc = AF.IdEstatusXML
				LEFT JOIN	S_Proveedor AS PV
					ON PV.RFC = AP.IdProveedor AND PV.Activo = 1
				LEFT JOIN dbo.FI_FacturaEliminada AS FE
				 ON FE.IdFactura = AF.IdFactura
				 LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = AP.IdProveedor
				WHERE (AP.IdSubContratista = @IdProveedor or AP.IdSubContratista = @SAPVENDOR)
							AND FE.IdFacturaEliminada IS NOT NULL	--> SI LA ACEPTACION DE FACTURA ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA	EN FILTRO, SE MUESTRA EN TODAS CON ESTATUS/INACTIVO
				GROUP BY	AP.IdAceptacionPedido, 
							AP.IdPedido, 
							PV.RazonSocial, 
							PV.RegimenCapital, 
							APC.FechaEvaluacion ,
							APC.IdEstatusEliminado,
							TVDF.TipoValidacion,
							AF.IdAceptacionFactura,
							AP.IdProveedor,
							CO.NombreContratista
				ORDER BY	AP.IdAceptacionPedido DESC
			END

		IF @Estatus = 4 ---Todas las aceptaciones que requieren de una factura y estatus de aprobación
			BEGIN
				SELECT		AP.IdAceptacionPedido, 
							AP.IdPedido ,
							ISNULL(CO.NombreContratista,AP.IdProveedor) AS Cliente ,
							APC.FechaEvaluacion AS FechaAperturaCarga ,
							ISNULL(TVDF.TipoValidacion, 'Sin Iniciar Aprobación') AS EstatusCarga,
							AF.IdAceptacionFactura
				FROM MPY_MM_AceptacionPedido AS AP
				LEFT JOIN	MPY_MM_AceptacionCartaPCN AS APC
					ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN	MPY_MM_AceptacionFactura AS AF
					ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN	S_TipoValidacionDoc AS TVDF
					ON TVDF.IdTipoValidacionDoc = AF.IdEstatusXML
				LEFT JOIN	S_Proveedor AS PV
					ON PV.RFC = AP.IdProveedor AND PV.Activo = 1
				LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = AP.IdProveedor
				WHERE (AP.IdSubContratista = @IdProveedor or AP.IdSubContratista = @SAPVENDOR)
							AND APC.IdEstatus = 2
							AND APC.FechaEvaluacion IS NOT NULL
							AND ISNULL ( AF.IdEstatusEliminado, 0 ) <> 1	--> SI LA ACEPTACION DE FACTURA ESTA ELIMINADA NO SE DEBE MOSTRAR ESTA SOLICITUD DE FACTURA	EN FILTRO, SE MUESTRA EN TODAS CON ESTATUS/INACTIVO
				GROUP BY	AP.IdAceptacionPedido, 
							AP.IdPedido, 
							PV.RazonSocial, 
							PV.RegimenCapital, 
							APC.FechaEvaluacion ,
							APC.IdEstatusEliminado,
							TVDF.TipoValidacion,
							AF.IdAceptacionFactura,
							AP.IdProveedor,
							CO.NombreContratista
				ORDER BY	AP.IdAceptacionPedido DESC
			END 
	END 
