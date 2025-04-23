USE Adinco
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_AP_RegistroFlujoAprobacion'
    )
    DROP PROCEDURE USP_INS_AP_RegistroFlujoAprobacion;
GO
CREATE PROCEDURE USP_INS_AP_RegistroFlujoAprobacion
    @IdUsuario INT,
    @IdContrato INT,
	@FlujoAprobacionId INT = 0,
	@IdContratistaSeleccionado INT,
	@TipoFlujoAprobacionId INT,
	@Descripcion VARCHAR(MAX),
	@Activo BIT
AS
BEGIN
DECLARE @IdContratista INT = 0;

IF EXISTS(
	SELECT * FROM AP_FlujoAprobacion (NOLOCK) WHERE FlujoAprobacionId <>  @FlujoAprobacionId AND IdContratista	=	@IdContratistaSeleccionado
)
BEGIN
	SELECT 'Ya existe un flujo de aprobación con el mismo contratista' AS Mensaje;
END
ELSE
BEGIN
	IF(@FlujoAprobacionId=0)
	BEGIN
	
		SELECT @FlujoAprobacionId =(MAX(FlujoAprobacionId)+1) FROM  AP_FlujoAprobacion (NOLOCK);

		INSERT INTO AP_FlujoAprobacion 
		(FlujoAprobacionId,IdContratista,Descripcion,TipoFlujoAprobacionId,Activo,CreadoEl,CreadoPor) VALUES 
		(@FlujoAprobacionId,@IdContratistaSeleccionado,@Descripcion,@TipoFlujoAprobacionId,@Activo,GETDATE(),@IdUsuario);
	END
	ELSE
	BEGIN

		SELECT @IdContratista	=	IdContratista FROM AP_FlujoAprobacion (NOLOCK) WHERE FlujoAprobacionId = @FlujoAprobacionId;

		IF(@IdContratista <> @IdContratistaSeleccionado)
		BEGIN
			DELETE AP_FlujoAprobacionContratos WHERE FlujoAprobacionId = @FlujoAprobacionId;
		END

		UPDATE AP_FlujoAprobacion
		SET 
			IdContratista = @IdContratistaSeleccionado,
			Descripcion = @Descripcion,
			TipoFlujoAprobacionId = @TipoFlujoAprobacionId,
			Activo = @Activo
		WHERE 
			FlujoAprobacionId = @FlujoAprobacionId;
		END
	
		SELECT 
		'Se ha guardado exitosamente' AS Mensaje,
		FlujoAprobacionId,
		IdContratista,
		Descripcion,
		TipoFlujoAprobacionId,
		Activo,
		CreadoEl,
		CreadoPor
		FROM  
			AP_FlujoAprobacion (NOLOCK)	WHERE FlujoAprobacionId = @FlujoAprobacionId;
	END
END
