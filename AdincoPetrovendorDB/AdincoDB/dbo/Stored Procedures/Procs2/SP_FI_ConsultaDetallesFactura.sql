
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ConsultaDetallesFactura'
)
    DROP PROCEDURE SP_FI_ConsultaDetallesFactura
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 11/05/2018
-- Description:	Consulta de detalles de la Factura
-- =============================================
-- Author:		Marcos Garcia
-- Alter date:  04/02/2020
-- Description:	AgregarCapoConcat Serie/Folio
-- =============================================
-- Author:		Reyna Olvera
-- Alter date:  09/08/2022
-- Description:	SE ELIMINA 1 LEFY JOIN, AGREGADO DE NOLOCK, MODIFICACIÓN DE LEFT JOINS (TABLAS EN EL ON DERECHA IZQUIERDA)
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaDetallesFactura]--56744
	@IdFactura INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		FAC.IdFactura, 
		FAC.Serie, 
		FAC.Folio, 
		FAC.Emisor,
		FAC.Receptor,
		FAC.SubTotal, 
		FAC.MontoConIva, 
		FAC.Moneda, 
		FAC.LugarExpedicion, 
		FAC.FechaTimbrado, 
		FAC.FechaRecepcion,
		CONVERT(DATE,FAC.Fecha) AS Fecha,
		FAC.CondicionesDePago,
		FAC.UUID,
		FAC.TipoComprobante,
		FDOC.DocumentoByte,
		ISNULL(FAC.XML,'') AS XML,
		ISNULL(EFAC.Estatus,'En Aprobación de Pago') AS EstatusPago, 
		ISNULL(US.Nombre,'Sin Aprobador') AS UsuarioAprobador,
		PSB.RazonSocial,
		FAC.FormaPago,
		FAC.UsoCFDI,
		FAC.VersionCFDI,
		LTRIM(CONCAT('Serie: ',ISNULL(FAC.Serie,'-'),' | Folio: ',ISNULL(FAC.Folio,'-'))) AS SerieFolio
	FROM 
		dbo.FI_Factura AS FAC	(NOLOCK)
	JOIN 
		dbo.PV_Subcontratista AS PSB	(NOLOCK)
		ON	FAC.IdSubcontratista	=	 PSB.IdSubcontratista
	LEFT JOIN 
		dbo.FI_AprobacionFactura AS AFAC	(NOLOCK)
		ON	FAC.IdFactura = @IdFactura
		AND	FAC.IdFactura	=	AFAC.IdFactura
	LEFT JOIN 
		dbo.FI_Estatus AS EFAC	(NOLOCK)
		ON AFAC.IdEstatus	=	 EFAC.IdEstatus
	LEFT JOIN 
		dbo.AP_Usuario AS US	(NOLOCK)
		ON AFAC.IdUsuarioAprobador	=	US.UsuarioID
	LEFT JOIN 
		dbo.FI_Documento AS FDOC	(NOLOCK)
		ON  FAC.IdFactura	=	FDOC.IdFactura
	WHERE 
		FAC.IdFactura = @IdFactura
	ORDER BY FAC.Fecha DESC
END
