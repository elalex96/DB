-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[SP_MPY_EnvioDocsWS]
	-- Add the parameters for the stored procedure here
	@RFCOPERADORA NVARCHAR(20),
	@IdPedido INT
AS
BEGIN     
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IDACEPTACIONPEDIDO INT = (SELECT IdAceptacionPedido FROM dbo.MPY_MM_AceptacionPedido WHERE IdPedido = @IdPedido AND IdProveedor = @RFCOPERADORA);

	DECLARE @IDACEPTACIONPCN INT = (SELECT IdAceptacionCartaPCN FROM dbo.MPY_MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IDACEPTACIONPEDIDO AND IdEstatus = 2);

	DECLARE @IDACEPTACIONFACTURA INT = (SELECT IdAceptacionFactura FROM dbo.MPY_MM_AceptacionFactura WHERE IdAceptacionPedido = @IDACEPTACIONPEDIDO AND IdEstatus = 2);

	DECLARE @IDFACTURA INT = (SELECT IdFactura FROM dbo.MPY_MM_AceptacionFactura WHERE IdAceptacionFactura = @IDACEPTACIONFACTURA);

	CREATE TABLE #DOCUMENTOS
	(
		TipoDoc INT,
		Carpeta NVARCHAR(MAX),
		NombreDoc NVARCHAR(MAX),
		Extension NVARCHAR(MAX),
		Identificador NVARCHAR(MAX),
		Mime NVARCHAR(MAX),
		FacturaXML NVARCHAR(MAX),
		FacturaPDF IMAGE
	)

	--1 = FACTURA
	--2 = CARTA CONTENIDO NACIONAL
	--3 = DOCUMENTOS DE SOPORTE

	INSERT INTO #DOCUMENTOS (TipoDoc,FacturaXML, FacturaPDF)
	SELECT 1, XML, ComprobantePDFByte 
	FROM dbo.FI_Factura WHERE IdFactura = @IDFACTURA

	INSERT INTO #DOCUMENTOS (TipoDoc,Carpeta,NombreDoc,Extension,Identificador,Mime)
	SELECT 2, Carpeta,NombreDocumento,Extension,Identificador,Mime 
	FROM dbo.S_Documento_S3 WHERE IdDocumento = @IDACEPTACIONPCN

	INSERT INTO #DOCUMENTOS (TipoDoc,Carpeta,NombreDoc,Extension,Identificador,Mime)
	SELECT 3, Carpeta,NombreDoc,Extension,Identificador,Mime 
	FROM dbo.MPY_MM_DocSoporteRecepcionFactura WHERE IdAceptacionPedido = @IDACEPTACIONPEDIDO

	SELECT * FROM #DOCUMENTOS
	
END
