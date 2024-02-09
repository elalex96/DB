use Petrovendor
go
drop proc if exists SP_TA_ConsultarTareasAprobador
go
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 09-04-17
-- Description:	Regresa la informaci�n de las tareas por aprobar por el usuario actual
-- Update Agregue idproveedor y idcontrato 01-03-2018 DAC			
-- =============================================
-- Author:		Jose Roman
-- Create date: 15-08-2018
-- Description:	Se filtran las aprobaciones de tipo serial, donde los aprobadores con numero de secuencia menos aun no han aprobado la operacion			
-- =============================================
-- Author:		Luis David
-- Create date: 8 Febrero 2024
-- Description:	Se reamocodan los joins y se agrega rango de fechas
-- =============================================
CREATE PROCEDURE SP_TA_ConsultarTareasAprobador
    -- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @IdProveedor INT,
    @IdContrato INT,
	@FechaInicio datetime null,
	@FechaFin datetime null
AS
BEGIN

    SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,           
		   E.Nombre AS Nombre
    FROM TA_Operacion AS O (NOLOCK)
	INNER JOIN TA_TipoOperacion AS OT (NOLOCK) ON O.IdTipoOperacion = OT.IdTipoOperacion
    INNER JOIN TA_Estatus AS E (NOLOCK) ON O.IdEstatusOperacion = E.IdEstatus
    INNER JOIN TA_TareaOperacion (NOLOCK) AS TTO ON O.IdOperacion = TTO.IdOperacion
    INNER JOIN TA_Tarea AS T (NOLOCK) ON TTO.IdTarea = T.IdTarea
    WHERE T.IdAprobador = @IdUsuario
			AND O.IdTipoOperacion = 2
			AND O.IdProveedor = @IdProveedor
			AND ISNULL(O.IdEstatusEliminado, 0) <> 1  --> MOSTRAR NO ELIMINADAS 
			AND O.IdOperacion NOT IN (SELECT IdOperacion FROM dbo.FN_FlujoSerialNoAprobados(@IdUsuario,@IdProveedor,2))
			AND cast(O.FechaRegistro as date) BETWEEN cast(@FechaInicio as date) and cast(@FechaFin as date)
AND T.idestatus = 1 -->No mostrar si ya se aprobo MG 
    GROUP BY O.IdOperacion,
			O.IdDocumento,
			O.FechaRegistro,
			O.Descripcion,
			E.Nombre,
			O.IdEstatusEliminado
    ORDER BY O.FechaRegistro DESC;

END;
