IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_CO_ActualizarProgramaConBitacora'
)
    DROP PROCEDURE USP_UPD_CO_ActualizarProgramaConBitacora
GO

CREATE PROCEDURE [dbo].USP_UPD_CO_ActualizarProgramaConBitacora  
	@ContratoIdSeleccionado INT,
	@IdPrograma INT,
	@NombrePrograma VARCHAR(MAX),
	@ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN

        SET NOCOUNT ON;

		DECLARE @NombreProgramaAnterior VARCHAR(MAX)

		SELECT @NombreProgramaAnterior = NombrePrograma 
		FROM CO_ProgramaActividad WHERE IdProgramaActividad = @IdPrograma


        INSERT INTO AP_Bitacora
        (
            [Fecha],
            [Tipo],
            [Mensaje],
            [Detalle],
            [UsuarioId],
            [ContratoId]
        )
        VALUES
        (GETDATE(),
            'Edición',
            'Edición de Valores de CO_ProgramaActividad en la página AdministrarPresupuesto.aspx',
            CONCAT(
                    'Del contrato seleccionado con id: ',
                    CONVERT(VARCHAR(10), @ContratoIdSeleccionado),
                    ' - ',
                    ' y del Programa con id: ',
                    CONVERT(VARCHAR(10), @IdPrograma),
                    ' -',
                    CONCAT('Programa: Antes [ ', @NombreProgramaAnterior, ' ] ', ' Después: [ ', @NombrePrograma, ' ]')
                ),
            @UsuarioId,
            @ContratoId
        );

		UPDATE CO_ProgramaActividad
		SET NombrePrograma = @NombrePrograma,
		ModificadoEl = GETDATE(),
		ModificadoPor = @UsuarioId
		WHERE IdProgramaActividad = @IdPrograma

        SELECT 'CORRECTO';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH

        ROLLBACK TRAN;

        SELECT CONCAT('Error: USP_UPD_CO_ActualizarProgramaConBitacora - ', ERROR_MESSAGE());

    END CATCH;
END;