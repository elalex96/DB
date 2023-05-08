
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 09-04-17
-- Description:	muestra la informaci�n de las aprobaciones de solcitud de pedido que un requitor realiza		
-- Author:		Daniel Cruz
-- Update date: 04-06-18
-- Description:	Descartar aprobaciones con estatus de eliminaci�n activo =1 	
-- =============================================
-- Author:		Jose Roman
-- Create date: 24-09-2018
-- Description:	Se filtran las aprobaciones de tipo serial, donde los aprobadores con numero de secuencia menos aun no han aprobado la operacion			
-- =============================================
CREATE PROCEDURE SP_TA_ConsultarTareasAsignadas
    -- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @IdProveedor INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,
           E.Nombre
    FROM TA_Operacion AS O
        INNER JOIN TA_TipoOperacion AS OT
            ON OT.IdTipoOperacion = O.IdTipoOperacion
        INNER JOIN TA_Estatus AS E
            ON E.IdEstatus = O.IdEstatusOperacion
    WHERE O.IdAsignador = @IdUsuario
          AND O.IdTipoOperacion = 2
          AND O.IdProveedor = @IdProveedor
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 --> que no esten eliminadas
			AND O.IdOperacion NOT IN (SELECT IdOperacion FROM dbo.FN_FlujoSerialNoAprobados(@IdUsuario,@IdProveedor,2))
    ORDER BY O.IdOperacion DESC;


END;



