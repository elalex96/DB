IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_CO_ActualizarPeriodoConBitacora'
)
    DROP PROCEDURE USP_UPD_CO_ActualizarPeriodoConBitacora
GO

CREATE PROCEDURE [dbo].[USP_UPD_CO_ActualizarPeriodoConBitacora]  
	@ContratoIdSeleccionado INT,
	@IdPeriodo INT,
	@NombrePeriodo VARCHAR(MAX),
	@ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN

        SET NOCOUNT ON;

		DECLARE @NombrePeriodoAnterior VARCHAR(MAX)

		SELECT @NombrePeriodoAnterior = NombrePeriodo 
		FROM CO_PeriodoContrato WHERE IdPeriodo = @IdPeriodo


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
            'Edición de Valores de CO_PeriodoContrato en la página AdministrarPresupuesto.aspx',
            CONCAT(
                    'Del contrato seleccionado con id: ',
                    CONVERT(VARCHAR(10), @ContratoIdSeleccionado),
                    ' - ',
                    ' y del Periodo con id: ',
                    CONVERT(VARCHAR(10), @IdPeriodo),
                    ' -',
                    CONCAT('Periodo: Antes [ ', @NombrePeriodoAnterior, ' ] ', ' Después: [ ', @NombrePeriodo, ' ]')
                ),
            @UsuarioId,
            @ContratoId
        );

		UPDATE CO_PeriodoContrato
		SET NombrePeriodo = @NombrePeriodo,
		ModificadoEl = GETDATE(),
		ModificadoPor = @UsuarioId
		WHERE IdPeriodo = @IdPeriodo

        SELECT 'CORRECTO';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH

        ROLLBACK TRAN;

        SELECT CONCAT('Error: USP_UPD_CO_ActualizarPeriodoConBitacora - ', ERROR_MESSAGE());

    END CATCH;
END;