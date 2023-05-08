-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_AD_ConsultaFacturasAdmin 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS Num,
		FAC.IdFactura AS IdFacturaPrincipal, 
		ISNULL(CAST(AFAC.IdAceptacionFactura AS NVARCHAR(MAX)), 'Factura sin Aceptacion') AS IdAceptacionFactura,
		ISNULL(AFAC.IdFactura,FAC.IdFactura) AS IdFactura,
		ISNULL(ESFAC.Nombre,'Sin Estado de Aprobacion') AS EstatusAprobacion, 
		FAC.SubTotal, 
		FAC.MontoConIva, 
		FAC.Moneda,
		FAC.LugarExpedicion, 
		FAC.Emisor, 
		FAC.Receptor,
		FAC.UUID, 
		FAC.FechaTimbrado, 
		FAC.FechaRecepcion,
		AFAC.FechaCargaPDF,
		AFAC.FechaCargaXML
	FROM dbo.FI_Factura AS FAC
	LEFT JOIN dbo.MM_AceptacionFactura AS AFAC ON AFAC.IdFactura = FAC.IdFactura
	LEFT JOIN dbo.TA_Operacion AS TA ON TA.IdDocumento = AFAC.IdAceptacionFactura
	LEFT JOIN dbo.TA_Estatus AS ESFAC ON ESFAC.IdEstatus = TA.IdEstatusOperacion
	ORDER BY AFAC.FechaCargaXML DESC
END
