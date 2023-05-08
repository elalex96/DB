-- =============================================
-- Author:		Pedro, Acuña
-- Create date: 13/02/2018
-- Description:	Revisar el estatus de la aprobacion de la compra directa
-- =============================================
CREATE PROCEDURE SP_CD_RevisarEstatusAprobador
    @IdUsuario INT,
	@IdTipoOperacion INT,
	@IdOperacion INT,
    @IdContrato INT,
    @FechaRegistro DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TT.IdAprobador,
           TT.NoSecuencia,
           U.Nombre AS Aprobadores,
           TT.IdEstatus,
           TE.Nombre,
           TT.Comentario,
           TT.FechaCambioEstatus
    FROM TA_Estatus TE
        INNER JOIN TA_Tarea TT
            ON TE.IdEstatus = TT.IdEstatus
        INNER JOIN S_Usuario U
            ON U.IdUsuario = TT.IdAprobador
        INNER JOIN TA_Operacion TAO
            ON TT.IdOperacion = TAO.IdOperacion
    WHERE TAO.IdTipoOperacion = @IdTipoOperacion
          AND TT.IdOperacion = @IdOperacion
		  AND U.IdUsuario = @IdUsuario
    ORDER BY TT.NoSecuencia ASC


END
