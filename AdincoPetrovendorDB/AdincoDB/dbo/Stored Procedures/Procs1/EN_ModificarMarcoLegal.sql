USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_ModificarMarcoLegal'
)
    DROP PROCEDURE EN_ModificarMarcoLegal;
GO

/****** Object:  StoredProcedure [dbo].[EN_ModificarMarcoLegal]    Script Date: 11/11/2022 02:29:01 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =================================================================
-- Author:	Alexander Gomez
-- Create date: 30/06/2022
-- Description:	se agregan validaciones al editar el alias del marco legal para contract files
-- =================================================================
-- =================================================================
-- Author:	Daniel AC
-- Create date: 10/11/2022
-- Description:	Se agrega registro en bitacora el cambio realizado
-- =================================================================
CREATE PROCEDURE [dbo].[EN_ModificarMarcoLegal] --[EN_ModificarMarcoLegal] 'SASISOPA Programa de Desarrollo 2019-2021',10137,10536,3,1,'',0,'PRUEBA2'
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

	INSERT INTO dbo.AP_BitacoraErrores
	(HResult,
	 Mensaje,
	 StackTrace,
	 IdUsuario,
	 IdContrato,
	 FechaRegistro
	)
	VALUES
	(0, -- HResult - int
	'Se eliminó la información de la tabla EN_SecuenciaCarpetas y se edito la información de la tabla EN_CarpetasArchivosVisor/EN_CF_SolicitUDescargaCarpetas', -- Mensaje - nvarchar(max)
	 CONCAT('Marco Legal[',@IdMarcoLegal,'] Antes: ',@ALIAS_ANTERIOR,' Despues: ',@ML_NUEVO), -- StackTrace - nvarchar(max)
	 @idUsuario, -- IdUsuario - int
	 @idContrato,
	 GETDATE()
	);

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