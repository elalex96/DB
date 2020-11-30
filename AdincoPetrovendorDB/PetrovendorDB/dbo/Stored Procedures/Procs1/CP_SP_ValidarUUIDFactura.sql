
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <03-12-2018>
-- Description:	<Se consulta el UUID de una factura incluida en un complemento de pago, para validar que exista>
-- =============================================

CREATE PROCEDURE [dbo].[CP_SP_ValidarUUIDFactura] --'22v69cbm7-2l7f-66bb-a5b1-88ao4f2653e2',44
	@UUID NVARCHAR(150),
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	
	DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);

	SELECT pFact.IdFactura
	FROM Adinco.dbo.FI_Factura aFact
        LEFT JOIN Petrovendor.dbo.FI_Factura pFact	ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
        LEFT JOIN dbo.MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
		INNER JOIN dbo.MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
		INNER JOIN dbo.MM_Pedido p ON p.IdPedido = acepPed.IdPedido
        LEFT JOIN Petrovendor.dbo.TA_Operacion TAO ON TAO.IdDocumento = acepFact.IdAceptacionFactura
    WHERE TAO.IdEstatusOperacion = 2 --aprobadas
          AND aFact.Activa = 1
          AND pFact.Activa = 1
          AND TAO.IdProveedor = @IdProveedor
		  AND aFact.UUID = @UUID
	UNION
	SELECT pFact.IdFactura
	FROM Adinco.dbo.FI_Factura aFact
		LEFT JOIN Petrovendor.dbo.FI_Factura pFact	ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
		LEFT JOIN dbo.MPY_MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
		INNER JOIN dbo.MPY_MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
    WHERE acepFact.IdEstatus = 2 --aprobadas
          AND aFact.Activa = 1
          AND pFact.Activa = 1
          AND pFact.Emisor = @PROVEDORRFC
		  AND aFact.UUID = @UUID
END