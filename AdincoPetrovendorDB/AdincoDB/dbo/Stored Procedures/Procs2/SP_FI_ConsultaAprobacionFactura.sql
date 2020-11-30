-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/05/2018
-- Description:	Consulta de todas las facturas mosatrando su estatus de aprobacion de pago
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaAprobacionFactura] --3,10001
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@Estatus INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @Estatus = 10001
	BEGIN
		SELECT 
		FAC.IdFactura, 
		FAC.Serie, 
		FAC.Serie +'-'+ FAC.Folio as Folio, 
		'[' +FAC.Emisor +'] ' + SC.razonsocial  as Emisor,
		FAC.UUID AS Receptor,
		FAC.SubTotal, 
		FAC.MontoConIva, 
		FAC.Moneda, 
		FAC.LugarExpedicion, 
		FAC.FechaTimbrado, 
		FAC.FechaRecepcion,
		FAC.Fecha,
		ISNULL(EFAC.Estatus,'En Aprobación de Pago') AS EstatusPago, 
		ISNULL(US.Nombre,'Sin Aprobador') AS UsuarioAprobador
	FROM dbo.FI_Factura AS FAC
	LEFT JOIN dbo.FI_AprobacionFactura AS AFAC ON AFAC.IdFactura = FAC.IdFactura
	LEFT JOIN dbo.FI_Estatus AS EFAC ON EFAC.IdEstatus = AFAC.IdEstatus
	LEFT JOIN dbo.AP_Usuario AS US ON US.UsuarioID = AFAC.IdUsuarioAprobador
LEFT JOIN dbo.Pv_subcontratista SC on SC.idsubcontratista = FAC.idsubcontratista
	WHERE FAC.IdContrato = @IdContrato AND EFAC.IdEstatus IS NULL
	ORDER BY FAC.Fecha DESC
	END
	ELSE
	BEGIN
		SELECT 
		FAC.IdFactura, 
		FAC.Serie, 
		FAC.Serie +'-'+ FAC.Folio as Folio, 
		'[' +FAC.Emisor +'] ' + SC.razonsocial  as Emisor,
		FAC.UUID AS Receptor,
		FAC.SubTotal, 
		FAC.MontoConIva, 
		FAC.Moneda, 
		FAC.LugarExpedicion, 
		FAC.FechaTimbrado, 
		FAC.FechaRecepcion,
		FAC.Fecha,
		ISNULL(EFAC.Estatus,'En Aprobación de Pago') AS EstatusPago, 
		ISNULL(US.Nombre,'Sin Aprobador') AS UsuarioAprobador
	FROM dbo.FI_Factura AS FAC
	LEFT JOIN dbo.FI_AprobacionFactura AS AFAC ON AFAC.IdFactura = FAC.IdFactura
	LEFT JOIN dbo.FI_Estatus AS EFAC ON EFAC.IdEstatus = AFAC.IdEstatus
	LEFT JOIN dbo.AP_Usuario AS US ON US.UsuarioID = AFAC.IdUsuarioAprobador
	LEFT JOIN dbo.Pv_subcontratista SC on SC.idsubcontratista = FAC.idsubcontratista
	LEFT JOIN dbo.FI_TransferFactura	TF
		ON	FAC.IdFactura	=	TF.IdFactura
	WHERE FAC.IdContrato = @IdContrato AND EFAC.IdEstatus = @Estatus
		AND TF.IdTransferFactura IS NULL
	ORDER BY FAC.Fecha DESC
	END
	
END

