USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DROPBOX_GuardadoArchivosFactura]    Script Date: 04/03/2022 01:04:55 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <02/03/2022>
-- Description:	<Guardado de los archivos pertinentes a la factura para guardado en dropbox>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DROPBOX_GuardadoArchivosFactura] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ANIO VARCHAR(10);
	DECLARE @MES VARCHAR(10);
	DECLARE @NOMBRE_PROVEEDOR VARCHAR(100);
	DECLARE @FOLIO VARCHAR(100);
	DECLARE @IDFACTURA VARCHAR(100);
	DECLARE @RFC VARCHAR(100) = (SELECT RFC FROM S_Proveedor WHERE IdProveedor = @IdProveedor)

	--VALIDACION AMATITLAN
	IF @RFC IN ('DDM0906096A6','PAM140722DK6')
	BEGIN
		
		SELECT
			@ANIO = CAST(YEAR(F.FechaTimbrado) AS VARCHAR),
			@MES = CAST(MONTH(F.FechaTimbrado) AS VARCHAR),
			@NOMBRE_PROVEEDOR = PR.RazonSocial,
			@FOLIO = F.Folio,
			@IDFACTURA = F.IdFactura
		FROM MM_AceptacionFactura AS AF
			JOIN FI_Factura AS F ON AF.IdFactura = F.IdFactura
			JOIN S_Proveedor AS PR ON F.Emisor = PR.RFC
		WHERE AF.IdAceptacionPedido = @IdAceptacionPedido;

		IF CAST(@MES AS INT) < 10
		BEGIN
			SET @MES = '0' + @MES;
		END

		--GUARDADO DE LA FACTURA PDF
		INSERT INTO DR_ArchivosEnvioDropbox(
			Extension,
			Mime,
			NombreDocumento,
			AprobadoEl,
			Archivo,
			IsFactura,
			RutaDestino
		)
		SELECT
			'.pdf',
			'application/pdf',
			'F' + @FOLIO + '.pdf',
			GETDATE(),
			ComprobantePDFByte,
			1,
			'/2 INFORMES DE GE/' + @ANIO + '-' + @MES + ' INFORME GE/01 Soportes/PAT ' + @ANIO + '/' + @NOMBRE_PROVEEDOR + '/F ' + @FOLIO
		FROM FI_Factura 
		WHERE IdFactura = @IDFACTURA;

		--GUARDADO DE LA FACTURA XML
		INSERT INTO DR_ArchivosEnvioDropbox(
			Extension,
			Mime,
			NombreDocumento,
			AprobadoEl,
			Archivo,
			IsFactura,
			RutaDestino
		)
		SELECT
			'.xml',
			'application/xml',
			'F' + @FOLIO + '.xml',
			GETDATE(),
			ComprobanteXMLByte,
			1,
			'/2 INFORMES DE GE/' + @ANIO + '-' + @MES + ' INFORME GE/01 Soportes/PAT ' + @ANIO + '/' + @NOMBRE_PROVEEDOR + '/F ' + @FOLIO
		FROM FI_Factura 
		WHERE IdFactura = @IDFACTURA;

		--GUARDADO DE SOPORTES DE ACEPTACION DE PEDIDO 
		INSERT INTO DR_ArchivosEnvioDropbox(
			Extension,
			Mime,
			NombreDocumento,
			Identificador,
			Bucket,
			Folder,
			Size,
			AprobadoEl,
			IsSoporte,
			RutaDestino
		)
		SELECT      
			D.Extension, 
			D.Mime,
			D.NombreDocumento, 
			D.Identificador,
			D.Bucket,
			D.Carpeta,
			D.SizeDocumento,
			GETDATE(),
			1,
			'/2 INFORMES DE GE/' + @ANIO + '-' + @MES + ' INFORME GE/01 Soportes' 
		FROM        [dbo].[MM_AceptacionDocumento] AS AD
			INNER JOIN  [dbo].[MM_AceptacionPedido] AS AP
				ON AP.[IdAceptacionPedido] = AD.[IdAceptacionDocumento]
			INNER JOIN  [dbo].[S_Documento_S3] AS D
				ON	D.[IdDocumento] = AD.[IdDocumento]
		WHERE
			AP.[IdAceptacionPedido] = @IdAceptacionPedido
			AND AP.[IdProveedor] = @IdProveedor
			AND AD.[IdDocumento] IS NOT NULL
			AND AD.Activo = 1;

		--GUARDADO DE SOPORTES DE ACEPTACION DE PEDIDO 
		INSERT INTO DR_ArchivosEnvioDropbox(
			Extension,
			Mime,
			NombreDocumento,
			Identificador,
			Bucket,
			Folder,
			Size,
			AprobadoEl,
			IsSoporte,
			RutaDestino
		)
		SELECT
			DSF.Extension,
			DSF.Mime,
			DSF.NombreDoc,
			DSF.Identificador,
			DSF.Bucket,
			DSF.Carpeta,
			NULL,
			GETDATE(),
			1,
			'/2 INFORMES DE GE/' + @ANIO + '-' + @MES + ' INFORME GE/01 Soportes' 
		FROM dbo.MM_DocSoporteRecepcionFactura AS DSF
		WHERE IdAceptacionPedido = @IdAceptacionPedido
			AND Eliminado = 0;

		SELECT 'TRUE' AS RESPUES

	END
	ELSE
	BEGIN
		
		SELECT 'FALSE' AS RESPUES

	END
END