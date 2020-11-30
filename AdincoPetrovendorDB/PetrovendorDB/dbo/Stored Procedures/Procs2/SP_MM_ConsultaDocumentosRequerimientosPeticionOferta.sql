-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <25/09/2020>
-- Description:	<Consultar el conjunto de documentos como requerimientos minimos JAGUAR>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaDocumentosRequerimientosPeticionOferta] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @INE INT=0, @RFC INT=0, @C_DOMICILIO INT=0, @C_BANCARIA INT=0 
	DECLARE @Condicion BIT

	-- CONDICIONAMOS QUE LAS OPERADORAS SEAN LAS REGISTRADAS EN ESTA TABLA
	IF @IdProveedor IN (SELECT IdOperadora FROM dbo.CO_CONTRATOSJAGUAR)
		SET @Condicion = 1
	ELSE 
		SET @Condicion = 0
		
	/*SI EL PROVEEDOR ACTUAL ES DE JAGUAR DEBE REGRESAR LA CONDICIÓN 1 
	Y CON LA COLUMNA ISDEFAULT EN 1*/
	/*
	LOS DOCUMENTOS RELACIONADOS DEBEN SER 
	2	INE
	3	RFC 
	5	Comprobante de domicilio
	53	Cuenta bancaria
	*/	
	
	IF @Condicion=1
	BEGIN 
		/*OBTENER LOS IDS DE LOS DOCUMENTOS*/
		SELECT @INE=IdTipoDocumento
		FROM dbo.S_TipoDocumento
		WHERE LTRIM(RTRIM(NombreTipoDocumento))='INE'

		SELECT @RFC=IdTipoDocumento
		FROM dbo.S_TipoDocumento
		WHERE LTRIM(RTRIM(NombreTipoDocumento))='RFC'

		SELECT @C_DOMICILIO=IdTipoDocumento
		FROM dbo.S_TipoDocumento
		WHERE LTRIM(RTRIM(NombreTipoDocumento))='Comprobante de domicilio'

		SELECT @C_BANCARIA=IdTipoDocumento
		FROM dbo.S_TipoDocumento
		WHERE LTRIM(RTRIM(NombreTipoDocumento))='Cuenta bancaria'

	END 

    -- Insert statements for procedure here
	--PERSONA MORAL
	SELECT
	IdTipoDocumento,
	NombreTipoDocumento,
	CASE WHEN @Condicion = 1 THEN 
		CASE WHEN IdTipoDocumento IN (@INE,@RFC,@C_DOMICILIO,@C_BANCARIA) THEN 1 ELSE 0 END
	ELSE 0 END IsDefault
	FROM dbo.ConsultaDocumentos(1)

	--PERSONA FISICA
	SELECT
	IdTipoDocumento,
	NombreTipoDocumento,
	CASE WHEN @Condicion = 1 THEN 
		CASE WHEN IdTipoDocumento IN (@INE,@RFC,@C_DOMICILIO,@C_BANCARIA) THEN 1 ELSE 0 END
	ELSE 0 END IsDefault
	FROM dbo.ConsultaDocumentos(2)

	--PERSONA MORAL EXTRANJERA
	SELECT
	IdTipoDocumento,
	NombreTipoDocumento,
	CASE WHEN @Condicion = 1 THEN 
		CASE WHEN IdTipoDocumento IN (@INE,@RFC,@C_DOMICILIO,@C_BANCARIA) THEN 1 ELSE 0 END
	ELSE 0 END IsDefault
	FROM dbo.ConsultaDocumentos(3)

END


