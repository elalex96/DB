-- =====
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:busca procesos por ronda
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_SelectProcesosRondas]--3,10061,10009
    @idContrato INT,
    @idUsuario INT,
    @IdProceso INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT      r.idRonda,
                Seleccionado = CASE
                                    WHEN er.IdRonda IS NOT NULL THEN 1
                                    ELSE 0 END,
                r.Ronda
      FROM      EN_Rondas r
      LEFT JOIN EN_ProcesosRondas er
        ON er.IdRonda   = r.idRonda
       AND er.IdProceso = @IdProceso;
END;
--SELECT * FROM en_procesos