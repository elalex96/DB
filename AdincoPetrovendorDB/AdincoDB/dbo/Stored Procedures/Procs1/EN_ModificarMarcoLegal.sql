USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[EN_ModificarMarcoLegal]    Script Date: 20/07/2022 01:02:53 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================
-- Author:		Valeria Rodríguez
-- Create date: 03/01/2019
-- Description:	Modificación de datos en la tabla EN_MarcoLegal
-- =================================================================
-- =================================================================
-- Author:	Luis David
-- Create date: 27/09/2019
-- Description:	se agrega el bitjoa y nombreeningles para el issue 419
-- =================================================================
-- Author:		Reyna Olvera
-- Create date: 27/09/2019
-- Description: Modifica datos del marco legal
-- =================================================================
-- =================================================================
-- Author: Alexander Gomez
-- Create date: 20/06/2022
-- Description:	se agrega el Alias
-- =================================================================
-- =================================================================
-- Author:	Alexander Gomez
-- Create date: 30/06/2022
-- Description:	se agregan validaciones al editar el alias del marco legal para contract files
-- =================================================================
ALTER PROCEDURE [dbo].[EN_ModificarMarcoLegal] --[EN_ModificarMarcoLegal] 'SASISOPA Programa de Desarrollo 2019-2021',10137,10536,3,1,'',0,'PRUEBA2'
	@MarcoLegal VARCHAR(MAX),
	@IdMarcoLegal INT,
    @idUsuario INT,
    @idContrato INT,
	@activo bit,
	@MarcoLegalIngles VARCHAR(MAX) = null,
	@BitJoa bit = null,
	@Alias VARCHAR(1000) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @ML_ANTERIOR VARCHAR(MAX) = (SELECT MarcoLegal FROM EN_MarcoLegal WHERE IdMarcoLegal = @IdMarcoLegal);
	DECLARE @ALIAS_ANTERIOR VARCHAR(MAX) = (SELECT Alias FROM EN_MarcoLegal WHERE IdMarcoLegal = @IdMarcoLegal);
	DECLARE @ALIAS_ANTERIOR_IN VARCHAR(MAX) = (SELECT Alias FROM EN_MarcoLegal WHERE IdMarcoLegal = @IdMarcoLegal);
	DECLARE @ML_NUEVO VARCHAR(MAX);

	--VALIDACION PARA EL ARMADO DE LA RUTA ANTERIOR
	IF ISNULL(@ALIAS_ANTERIOR_IN,'') <> ''
	BEGIN
		
		SET @ML_ANTERIOR = @ML_ANTERIOR + ' - (' + @ALIAS_ANTERIOR + ')';
		SET @ML_ANTERIOR = REPLACE(@ML_ANTERIOR,'/','-')
		SET @ALIAS_ANTERIOR = @ML_ANTERIOR;

	END
	BEGIN
		
		SET @ALIAS_ANTERIOR = @ML_ANTERIOR;
		SET @ALIAS_ANTERIOR = REPLACE(@ALIAS_ANTERIOR,'/','-')
	END


	--VALIDACION PARA EL CAMBIO DE RUTAS
	IF @Alias <> '' OR @ALIAS_ANTERIOR_IN <> @ALIAS_ANTERIOR OR @MarcoLegal <> @ML_ANTERIOR
	BEGIN

		IF @Alias <> @ALIAS_ANTERIOR AND @ALIAS_ANTERIOR <> ''
		BEGIN

			SET @ML_NUEVO = @MarcoLegal + ' - (' + @Alias + ')';
			SET @ML_NUEVO = REPLACE(@ML_NUEVO,'/','-');

		END
	END

	--ACTUALIZACION DE RUTA EN LOS ARCHIVOS CARGADOS DEL MARCO LEGAL
	UPDATE EN_CarpetasArchivosVisor
	SET Ruta = REPLACE(Ruta,@ALIAS_ANTERIOR,@ML_NUEVO)--SE REMPLAZA EL MARCO LEGAL ANTERIOR EN LA RUTA
	WHERE Ruta LIKE '%' + @ALIAS_ANTERIOR + '%';

	--ACTUALIZACION DE LAS SOLICITUDES DE DESCARGA
	UPDATE EN_CF_SolicitUDescargaCarpetas
	SET RutaDescargada = REPLACE(RutaDescargada,@ALIAS_ANTERIOR_IN,@Alias)--SE REMPLAZA EL MARCO LEGAL ANTERIOR EN LA RUTA
	WHERE RutaDescargada LIKE '%' + @ALIAS_ANTERIOR_IN + '%'
	AND ISNULL(Procesado,0) = 0;

	--ELIMINADO DE LAS SECUENCIAS YA QUE AL CAMBIAR DE MARCO LEGAL CAMBIAN LA RUTA
	DELETE FROM EN_SecuenciaCarpetas

	UPDATE EN_MarcoLegal
	SET MarcoLegal = @MarcoLegal,
	Activo=@activo,
	MarcoLegalIngles = @MarcoLegalIngles,
	BitJOA = @BitJoa,
	ModificadoPor = @idUsuario,
	ModificadoEn = GETDATE(),
	Alias = @Alias
	WHERE IdMarcoLegal = @IdMarcoLegal;
	
END