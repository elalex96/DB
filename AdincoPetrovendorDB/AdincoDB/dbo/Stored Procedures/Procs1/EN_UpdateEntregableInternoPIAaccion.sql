-- =============================================
-- Author:		Reyna Olvera
-- Create date: 18/05/2019
-- Description:Guarda entregables internas
-- =============================================
CREATE PROCEDURE dbo.EN_UpdateEntregableInternoPIAaccion
    @idUsuario INT,
    @idContrato INT,
    @pDocumentoEntregable NVARCHAR(MAX),
    @pDescripcion NVARCHAR(MAX),
    @pIsActivo BIT,
    @pConsecutivo NVARCHAR(MAX),
    @pIdEntregable INT,
    @ReceptorEntregable VARCHAR(100),
    @IdFrecuenciaEntregable INT,
    @EsDeProceso BIT,
    @IdProgramaImplementaAccion INT,
    @IdContratoEntregable INT,
	@capitulo VARCHAR(500), 
	@articulo VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CountCEPIA INT,
            @IdReceptorEntregable INT;
	SELECT @IdReceptorEntregable =IdReceptorEntregable
    FROM dbo.EN_ReceptorEntregable
    WHERE ReceptorEntregable = @ReceptorEntregable;

	--SELECT @IdReceptorEntregable

    UPDATE dbo.EN_Entregable
    SET DocumentoEntregable = @pDocumentoEntregable,
        Descripcion = @pDescripcion,
        CreadoPor = @idUsuario,
        CreadoEn = GETDATE(),
        ModificadoPor = @idUsuario,
        ModificadoEn = GETDATE(),
        IsActivo = @pIsActivo,
        IsEliminado = IsEliminado,
        --Consecutivo = @pConsecutivo,
        IdReceptorEntregable = @IdReceptorEntregable,
        IdFrecuenciaEntregable = Case @IdFrecuenciaEntregable
		When 0
		then null
		Else
		@IdFrecuenciaEntregable
		END,
        EsDeProceso = @EsDeProceso,
		Capitulo=@capitulo,
		Articulo=@articulo
    WHERE IdEntregable = @pIdEntregable;

    IF (@IdContratoEntregable = 0 OR @IdContratoEntregable IS NULL)
    BEGIN
        SELECT @IdContratoEntregable = IdContratoEntregable
        FROM dbo.EN_ContratoEntregable
        WHERE IdContrato = @idContrato
              AND IdEntregable = @pIdEntregable;
    END;


    DELETE FROM EN_ContratoEntregableProgramaImplementaAcciones
    WHERE IdContratoEntregable = @IdContratoEntregable;

    INSERT INTO dbo.EN_ContratoEntregableProgramaImplementaAcciones (IdContratoEntregable,
                                                                     IdProgramaImplementaAccion,
                                                                     CreadoEl,
                                                                     CreadoPor,
                                                                     ModificadoEl,
                                                                     ModificadoPor,
                                                                     Activo)
    VALUES (@IdContratoEntregable,       -- IdContratoEntregable - int
            @IdProgramaImplementaAccion, -- IdProgramaImplementaAccion - int
            GETDATE(),                   -- CreadoEl - date
            @idUsuario,                  -- CreadoPor - int
            GETDATE(),                   -- ModificadoEl - date
            @idUsuario,                  -- ModificadoPor - int
            1                            -- Activo - bit
        );

    IF @@ERROR <> 0
        SELECT CAST(@@ERROR AS NVARCHAR(8)) AS error;
    ELSE
        SELECT '' AS error;
END;

