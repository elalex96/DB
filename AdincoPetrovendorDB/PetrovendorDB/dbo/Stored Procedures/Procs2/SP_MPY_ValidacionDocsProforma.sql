-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/01/2019
-- Description:	Consulta y validacion de documentos necesarios para la carga de la proformas, devuelve los documentos faltantes

/*

DOCUMENTOS PERSONA FÍSICA

-INE
-RFC
-COMPROBANTE DE DOMICILIO
-ESTADO DE CUENTA

*/
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_ValidacionDocsProforma] --44
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @IdTipoRegimen int


	select @IdTipoRegimen = IdTipoRegimen
	from S_Proveedor
	where Idproveedor = @IdProveedor

    -- Insert statements for procedure here

	CREATE TABLE #DOCSPROFORMA(
		TipoDocumento NVARCHAR(max),
		IdTipoDoc INT
	);

	IF(@IdTipoRegimen <> 2)
	BEGIN

		DECLARE @VAR INT;
	
		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 1--ACTA CONSTITUTIVA
					ORDER BY DOC.CreadoEl DESC);



		IF(ISNULL(@VAR,0) = 0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('Acta Constitutiva/Articles of Incorporation',1);
		END

	
		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 3
					ORDER BY DOC.CreadoEl DESC);--RFC

		IF(ISNULL(@VAR,0) = 0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('RFC/ Mexican Tax ID',3);
		END

	
		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 10
					ORDER BY DOC.CreadoEl DESC);--PODER NOTARIAL

		IF(ISNULL(@VAR,0) =0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('Poder Notarial/Power of attorney',10);
		END

	
		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 13
					ORDER BY DOC.CreadoEl DESC);--REPRESENTANTE LEGAL

		IF(ISNULL(@VAR,0) = 0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('Identificación del Representante Legal/ Legal Representative ID',13);
		END

	


	END
	IF(@IdTipoRegimen = 2)
	BEGIN

		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 2
					ORDER BY DOC.CreadoEl DESC);--RFC

		IF(ISNULL(@VAR,0) = 0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('INE',2);
		END
		

	
		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 3
					ORDER BY DOC.CreadoEl DESC);--RFC

		IF(ISNULL(@VAR,0) = 0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('RFC/ Mexican Tax ID',3);
		END

		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 5
					ORDER BY DOC.CreadoEl DESC);--Comprobante de Domicilio

		IF(ISNULL(@VAR,0) = 0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('Comprobante de Domicilio/ Address Proof',5);
		END

		SET @VAR = (SELECT
						TOP 1 ISNULL(DOC.IdDocumento,0)
					FROM dbo.S_Documento_S3 AS DOC
					WHERE DOC.IdProveedor = @IdProveedor
						AND DOC.Activo = 1
						AND DOC.IdTipoDocumento = 7
					ORDER BY DOC.CreadoEl DESC);--Comprobante de Domicilio

		IF(ISNULL(@VAR,0) = 0)
		BEGIN
			INSERT INTO #DOCSPROFORMA VALUES
			('Estado de Cuenta/ Account status',7);
		END
	
		

	END

	

	SELECT * FROM #DOCSPROFORMA;
END

