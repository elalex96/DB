
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30-11-2018>
-- Description:	<Se guarda el XML>
-- =============================================

create procedure [dbo].[MPY_FI_SP_InsertarXMLDocument]
	@ArchivoXML IMAGE,
	@HashSHA256 NVARCHAR(600),
	@IdFactura INT,
	@IdAceptacionPedido INT = null,
	@IdFacturaS int = NULL,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	IF(@IdAceptacionPedido IS NOT NULL)
	BEGIN
		SET @IdContrato = (SELECT AP.IdContrato
								FROM dbo.MPY_MM_AceptacionPedido AS AP
								WHERE AP.IdAceptacionPedido  = @IdAceptacionPedido)
	END
	ELSE
	BEGIN
		SET @IdContrato = (SELECT TOP 1 AP.IdContrato
								FROM dbo.MPY_MM_AceptacionPedido AS AP
								LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
								WHERE AF.IdFactura = @IdFactura
								ORDER BY AF.CreadoEl DESC);
	end

	INSERT INTO dbo.FI_ArchivoXml
	(
	    ArchivoXml,
	    HashSHA256,
	    IdFactura,
	    IdContrato,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    Activo
	)
	VALUES
	(   @ArchivoXML,      -- ArchivoXml - image
	    @HashSHA256,       -- HashSHA256 - nvarchar(600)
	    @IdFactura,         -- IdFactura - int
	    @IdContrato,         -- IdContrato - int
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    NULL,         -- ModificadoPor - int
	    NULL, -- ModificadoEl - datetime
	    1       -- Activo - bit
	)

	SELECT @@IDENTITY

END
