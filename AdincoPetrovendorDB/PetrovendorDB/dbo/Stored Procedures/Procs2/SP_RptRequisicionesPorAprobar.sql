-- =============================================
-- Author:	Pedro Acuña
-- Create date: 16-07-2018
-- Description:	SP que obtiene las Requisiciones por aprobar
-- =============================================

CREATE PROCEDURE SP_RptRequisicionesPorAprobar @IdProveedor INT, @IdContrato INT, @IdUsuario INT
AS
	BEGIN
		SELECT		O.IdOperacion, O.IdDocumento, O.FechaRegistro, O.Descripcion, E.Nombre AS Nombre
		FROM		TA_Operacion AS O
		INNER JOIN	TA_TipoOperacion AS OT
			ON OT.IdTipoOperacion = O.IdTipoOperacion
		INNER JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN	TA_TareaOperacion AS TTO
			ON TTO.IdOperacion = O.IdOperacion
		INNER JOIN	TA_Tarea AS T
			ON T.IdTarea = TTO.IdTarea
		WHERE
					O.IdTipoOperacion = 2
					AND O.IdProveedor = @IdProveedor
					AND T.IdEstatus = 1
					AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 --> MOSTRAR NO ELIMINADAS 
		GROUP BY	O.IdOperacion, O.IdDocumento, O.FechaRegistro, O.Descripcion, E.Nombre, O.IdEstatusEliminado
		ORDER BY	O.FechaRegistro DESC
	END