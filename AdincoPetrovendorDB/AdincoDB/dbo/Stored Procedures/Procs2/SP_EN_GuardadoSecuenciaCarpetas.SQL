USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_GuardadoSecuenciaCarpetas]    Script Date: 19/02/2022 05:50:56 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <13/01/2022>
-- Description:	<guardado de secuencia de carpetas>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_GuardadoSecuenciaCarpetas]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdCarpeta INT,
	@Nivel INT,
	@IdCarpetaAnterior INT,
	@NivelAnterior INT,
	@Frecuencia INT,
	@IsCarpetaUsuario BIT,
	@IsCarpetaUsuarioAnterior BIT,
	@Ruta VARCHAR(MAX),
	@RutaAnterior VARCHAR(MAX),
	@IdReceptorEntregable INT,
	@AnioMes NVARCHAR(10),
	@IsPozo BIT,
	@Etapa INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ID INT = (SELECT TOP 1 IdCarpeta 
						FROM EN_SecuenciaCarpetas 
						WHERE IdCarpeta = @IdCarpeta 
							AND Nivel  = @Nivel 
							AND IdContrato = @IdContrato 
							AND Frecuencia = @Frecuencia 
							AND Etapa = @Etapa
							AND AnioMes = @AnioMes
							AND IdReceptorEntregable = @IdReceptorEntregable
							AND IsPozo = @IsPozo
							AND Activo = 1);

	--VALIDACION DE EXISTENCIA DE LA SECUENCIA
	IF @ID IS NULL --AND @Nivel > 1
	BEGIN

		IF (@Nivel = 3)
		BEGIN
			
			SET @NivelAnterior = 2;
			SET @IdCarpetaAnterior = (SELECT TOP 1 IdCarpeta FROM EN_SecuenciaCarpetas WHERE IdContrato = @IdContrato AND Nivel = 2);

		END
		
		--GUARDADO DE LA SECUENCIA
		INSERT INTO EN_SecuenciaCarpetas
		(
			IdCarpeta,
			Nivel,
			IdCarpetaAnterior,
			NiveAnterior,
			IdContrato,
			Frecuencia,
			IsCarpetaUsuario,
			IsCarpetaUsuarioAnterior,
			Ruta,
			RutaAnterior,
			Activo,
			IdReceptorEntregable,
			IsPozo,
			Etapa,
			AnioMes
		)
		VALUES
		(
			@IdCarpeta,
			@Nivel,
			@IdCarpetaAnterior,
			@NivelAnterior,
			@IdContrato,
			@Frecuencia,
			@IsCarpetaUsuario,
			@IsCarpetaUsuarioAnterior,
			@Ruta,
			@RutaAnterior,
			1,
			@IdReceptorEntregable,
			@IsPozo,
			@Etapa,
			@AnioMes
		);

	END

	--SELECT @ID

END
