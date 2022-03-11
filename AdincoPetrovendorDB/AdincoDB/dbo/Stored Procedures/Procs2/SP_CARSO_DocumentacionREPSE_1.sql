USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaDocumentosRequerimientosPeticionOferta]    Script Date: 10/03/2022 06:45:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <25/09/2020>
-- Description:	<Consultar el conjunto de documentos como requerimientos minimos JAGUAR>
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_ConsultaDocumentosRequerimientosPeticionOferta] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @INE INT=0, @RFC INT=0, @C_DOMICILIO INT=0, @C_BANCARIA INT=0 
	DECLARE @Condicion BIT;
	DECLARE @PROVEEDORES_DOCUMENTOS_DEFAULT TABLE(
		RFC_PROVEEDOR VARCHAR(100),
		TIPO_DOCUMENTO VARCHAR(200)
	);

	--TIPO DE DOCUMENTO QUE LA OPERADORA QUIERE POR DEFAULT Y EL RFC DE LA OPERADORA
	INSERT INTO @PROVEEDORES_DOCUMENTOS_DEFAULT(RFC_PROVEEDOR,TIPO_DOCUMENTO) VALUES ('DDM0906096A6','Certificado de aprobación de REPSE');
	INSERT INTO @PROVEEDORES_DOCUMENTOS_DEFAULT(RFC_PROVEEDOR,TIPO_DOCUMENTO) VALUES ('OBT1708213V6','Certificado de aprobación de REPSE');

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
	ELSE 0 END IsDefault,
	CASE 
		WHEN PDD.TIPO_DOCUMENTO IS NOT NULL AND PR.RFC IS NOT NULL THEN 'checked'
		ELSE ''
	END IsDefaultProveedor--LA OPERADORA QUIERE POR DEFAULT ESTE DOCUMENTO
	FROM dbo.ConsultaDocumentos(1) AS D
	LEFT JOIN S_Proveedor AS PR
		ON PR.IdProveedor = @IdProveedor
	LEFT JOIN @PROVEEDORES_DOCUMENTOS_DEFAULT AS PDD
		ON D.NombreTipoDocumento = PDD.TIPO_DOCUMENTO
		AND PR.RFC = PDD.RFC_PROVEEDOR

	--PERSONA FISICA
	SELECT
	IdTipoDocumento,
	NombreTipoDocumento,
	CASE WHEN @Condicion = 1 THEN 
		CASE WHEN IdTipoDocumento IN (@INE,@RFC,@C_DOMICILIO,@C_BANCARIA) THEN 1 ELSE 0 END
	ELSE 0 END IsDefault,
	CASE 
		WHEN PDD.TIPO_DOCUMENTO IS NOT NULL AND PR.RFC IS NOT NULL THEN 'checked'
		ELSE ''
	END IsDefaultProveedor--LA OPERADORA QUIERE POR DEFAULT ESTE DOCUMENTO
	FROM dbo.ConsultaDocumentos(2) AS D
	LEFT JOIN S_Proveedor AS PR
		ON PR.IdProveedor = @IdProveedor
	LEFT JOIN @PROVEEDORES_DOCUMENTOS_DEFAULT AS PDD
		ON D.NombreTipoDocumento = PDD.TIPO_DOCUMENTO
		AND PR.RFC = PDD.RFC_PROVEEDOR

	--PERSONA MORAL EXTRANJERA
	SELECT
	IdTipoDocumento,
	NombreTipoDocumento,
	CASE WHEN @Condicion = 1 THEN 
		CASE WHEN IdTipoDocumento IN (@INE,@RFC,@C_DOMICILIO,@C_BANCARIA) THEN 1 ELSE 0 END
	ELSE 0 END IsDefault,
	CASE 
		WHEN PDD.TIPO_DOCUMENTO IS NOT NULL AND PR.RFC IS NOT NULL THEN 'checked'
		ELSE ''
	END IsDefaultProveedor--LA OPERADORA QUIERE POR DEFAULT ESTE DOCUMENTO
	FROM dbo.ConsultaDocumentos(3) AS D
	LEFT JOIN S_Proveedor AS PR
		ON PR.IdProveedor = @IdProveedor
	LEFT JOIN @PROVEEDORES_DOCUMENTOS_DEFAULT AS PDD
		ON D.NombreTipoDocumento = PDD.TIPO_DOCUMENTO
		AND PR.RFC = PDD.RFC_PROVEEDOR

END