-- =====
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:Inserta los procesos por ronda
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_InsertaProcesosRondas]
    @idContrato INT,
    @idUsuario INT,
    @IdRonda INT,
	@pMarcarSiNO BIT,
    @IdsProcesos INT
AS
BEGIN

    SET NOCOUNT ON;


    IF (@pMarcarSiNO = 0)
    BEGIN
        DELETE EN_ProcesosRondas
         WHERE idRonda      = @IdRonda
           AND IdProceso = @IdsProcesos;
    END;
    ELSE
    BEGIN
        IF NOT EXISTS (   SELECT 1
                            FROM EN_ProcesosRondas
                           WHERE IdRonda      = @IdRonda
                             AND IdProceso = @IdsProcesos)
        BEGIN
            INSERT INTO EN_ProcesosRondas (IdProceso,
                                              idRonda)
            VALUES (@IdsProcesos, @IdRonda);
        END;
    END;
END;
