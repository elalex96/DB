-- =============================================
-- Author:		Alexander Gomez
-- Create date: 26-06-2018
-- Description:	CONSULTA TODAS LAS FACTURAS POR APROBACION
-- =============================================
	CREATE   PROCEDURE [dbo].[SP_MPY_PR_MM_ListaFacturasAprobacion]
	 @IdProveedor int,
	 @Estatus int ,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor)
	
	IF @Estatus IN (1,2,3)
		BEGIN
				SELECT 
					AF.IdAceptacionPedido,
					AP.IdPedido, 
					AF.CreadoEl, 
					ISNULL(SV.VendorName,AP.IdSubContratista) As Proveedor,
					E.Nombre,  
					SUM((APD.Cantidad+APD.Excedente) * APD.PrecioUnitario) AS TotalPedido,
					SV.TaxID AS RFC
				FROM MPY_MM_AceptacionFactura AS AF
				LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus 
				LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1	
				WHERE AP.IdContrato = 10037
					AND AF.IdEstatus = @Estatus
					AND ISNULL(AF.IdEstatusEliminado,0)<>1 
				GROUP BY AF.IdAceptacionPedido,
					AP.IdPedido, 
					AF.CreadoEl, 
					PR.RazonSocial,
					Pr.RegimenCapital, 
					E.Nombre,
					AP.IdSubContratista, 
					PR.RFC,
					SV.TaxID,
					SV.VendorName
				ORDER BY AF.IdAceptacionPedido DESC
			
		 END 

	 IF @Estatus=0 
	 BEGIN
		SELECT AF.IdAceptacionPedido,
		AP.IdPedido,
		AF.CreadoEl, 
		ISNULL(SV.VendorName,PR.RazonSocial) As Proveedor, 		
		E.Nombre,
		SUM((APD.Cantidad+APD.Excedente) * APD.PrecioUnitario) AS TotalPedido,
		SV.TaxID AS RFC
		FROM MPY_MM_AceptacionFactura AS AF
				LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus
				LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
				LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE AP.IdContrato = 10037
		AND AF.IdAceptacionFactura IS NOT NULL 
		AND ISNULL(AF.IdEstatusEliminado,0)<>1 
	    GROUP BY AF.IdAceptacionPedido,
			AP.IdPedido,
			PR.RazonSocial,
			Pr.RegimenCapital, 
			E.Nombre,
			PR.RFC,
			AP.IdSubContratista,
			AF.IdEstatusEliminado,
			AF.CreadoEl,
			SV.VendorName,
			SV.TaxID
		ORDER BY AF.IdAceptacionPedido DESC
     END 
END



