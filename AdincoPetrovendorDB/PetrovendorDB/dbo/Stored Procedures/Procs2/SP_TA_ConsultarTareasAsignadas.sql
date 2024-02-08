use Petrovendor
go
drop proc if exists SP_TA_ConsultarTareasAsignadas
go
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
-- Author:		Luis David
-- Create date: 8 Febrero 2024
-- Description:	Se reamocodan los joins y se agrega rango de fechas
-- =============================================
CREATE PROCEDURE SP_TA_ConsultarTareasAsignadas
    -- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @IdProveedor INT,
    @IdContrato INT,
	@FechaInicio datetime null,
	@FechaFin datetime null
AS
BEGIN
    SET NOCOUNT ON;

    SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,
           E.Nombre
    FROM TA_Operacion AS O (NOLOCK)
        INNER JOIN TA_TipoOperacion AS OT (NOLOCK)
            ON O.IdTipoOperacion = OT.IdTipoOperacion
        INNER JOIN TA_Estatus AS E (NOLOCK)
            ON O.IdEstatusOperacion = E.IdEstatus
    WHERE O.IdAsignador = @IdUsuario
          AND O.IdTipoOperacion = 2
          AND O.IdProveedor = @IdProveedor
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 --> que no esten eliminadas
		  AND O.IdOperacion NOT IN (SELECT IdOperacion FROM dbo.FN_FlujoSerialNoAprobados(@IdUsuario,@IdProveedor,2))
		  AND O.FechaRegistro BETWEEN @FechaInicio and @FechaFin
    ORDER BY O.IdOperacion DESC;


END;
