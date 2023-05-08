
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <03-12-2018>
-- Description:	<Se consulta el UUID de una factura incluida en un complemento de pago, para validar que exista>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 11/01/2023
-- Description: Se agrega nolocks 
-- =============================================

CREATE PROCEDURE [dbo].[CP_SP_ValidarUUIDFactura] --'22v69cbm7-2l7f-66bb-a5b1-88ao4f2653e2',44
	@UUID NVARCHAR(150),
	@IdProveedor INT,
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
AS
BEGIN
	
	DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor (NOLOCK) WHERE IdProveedor = @IdProveedor);

	SELECT pFact.IdFactura
	FROM Adinco.dbo.FI_Factura aFact  (NOLOCK)
        JOIN Petrovendor.dbo.FI_Factura pFact	 (NOLOCK) ON aFact.UUID = pFact.UUID COLLATE Modern_Spanish_CI_AS
        JOIN dbo.MM_AceptacionFactura acepFact  (NOLOCK) ON pFact.IdFactura = acepFact.IdFactura 
		JOIN dbo.MM_AceptacionPedido acepPed  (NOLOCK) ON acepFact.IdAceptacionPedido = acepPed.IdAceptacionPedido
		JOIN dbo.MM_Pedido p  (NOLOCK) ON acepPed.IdPedido = p.IdPedido 
        JOIN Petrovendor.dbo.TA_Operacion TAO  (NOLOCK) ON acepFact.IdAceptacionFactura = TAO.IdDocumento 
    WHERE TAO.IdEstatusOperacion = 2 --CTE aprobadas
          AND aFact.Activa = 1
          AND pFact.Activa = 1
          AND TAO.IdProveedor = @IdProveedor
		  AND aFact.UUID = @UUID
	UNION
	SELECT pFact.IdFactura
	FROM Adinco.dbo.FI_Factura aFact
		JOIN Petrovendor.dbo.FI_Factura pFact	 (NOLOCK) ON aFact.UUID = pFact.UUID COLLATE Modern_Spanish_CI_AS
		JOIN dbo.MPY_MM_AceptacionFactura acepFact  (NOLOCK) ON pFact.IdFactura = acepFact.IdFactura 
		JOIN dbo.MPY_MM_AceptacionPedido acepPed  (NOLOCK) ON acepFact.IdAceptacionPedido = acepPed.IdAceptacionPedido 
    WHERE acepFact.IdEstatus = 2 --CTE aprobadas
          AND aFact.Activa = 1
          AND pFact.Activa = 1
          AND pFact.Emisor = @PROVEDORRFC
		  AND aFact.UUID = @UUID
END