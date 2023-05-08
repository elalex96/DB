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
CREATE PROCEDURE SP_TA_ConsultarTareasAprobador
    -- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @IdProveedor INT,
    @IdContrato INT
AS
BEGIN
	
	--DECLARE @FlujoSerial TABLE(IdOperacion INT)

	--INSERT INTO @FlujoSerial
	--(
	--    IdOperacion
	--)
	--SELECT IdOperacion 
	--FROM dbo.FN_FlujoSerialNoAprobados (@IdUsuario, @IdProveedor, 2)

    SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,           
		   E.Nombre AS Nombre
    FROM TA_Operacion AS O 
	INNER JOIN TA_TipoOperacion AS OT ON OT.IdTipoOperacion = O.IdTipoOperacion
    INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
    INNER JOIN TA_TareaOperacion AS TTO ON TTO.IdOperacion = O.IdOperacion
    INNER JOIN TA_Tarea AS T ON T.IdTarea = TTO.IdTarea
	--LEFT JOIN @FlujoSerial fs ON fs.IdOperacion = O.IdOperacion AND fs.IdOperacion IS NULL -- Se excluyen los flujos de tipo serial que no han sido aprobados por aprobadores superiores
    WHERE T.IdAprobador = @IdUsuario
			AND O.IdTipoOperacion = 2
			AND O.IdProveedor = @IdProveedor
			AND ISNULL(O.IdEstatusEliminado, 0) <> 1  --> MOSTRAR NO ELIMINADAS 
			AND O.IdOperacion NOT IN (SELECT IdOperacion FROM dbo.FN_FlujoSerialNoAprobados(@IdUsuario,@IdProveedor,2))
AND T.idestatus = 1 -->No mostrar si ya se aprobo MG 
    GROUP BY O.IdOperacion,
			O.IdDocumento,
			O.FechaRegistro,
			O.Descripcion,
			E.Nombre,
			O.IdEstatusEliminado
    ORDER BY O.FechaRegistro DESC;


END;