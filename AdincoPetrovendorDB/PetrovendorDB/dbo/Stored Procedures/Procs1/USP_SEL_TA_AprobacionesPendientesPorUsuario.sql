USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_TA_AprobacionesPendientesPorUsuario'
)
 DROP PROCEDURE USP_SEL_TA_AprobacionesPendientesPorUsuario;
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 05-05-2025  
-- Description: consultar tareas de solicitud de pedido pendientes de aprobación
-- =============================================  
CREATE PROCEDURE [dbo].[USP_SEL_TA_AprobacionesPendientesPorUsuario] 
    @ContratoId INT,
    @AprobadorActualId INT,
	@ProveedorId INT
AS
BEGIN
		

		SELECT O.IdOperacion,
		T.IdTarea,
		U.Nombre AS Aprobador,
        O.IdDocumento AS SolicitudPedidoId,
        O.FechaRegistro,
        O.Descripcion,           
		E.Nombre AS Estatus,
		TFT.Nombre AS TipoFlujo,
		AC.NombreAreaContractual AS Contrato,
		T.NoSecuencia
		FROM TA_Operacion AS O (NOLOCK)
		INNER JOIN MM_SolicitudPedido SP  (NOLOCK)
			ON O.IdDocumento = SP.IdSolicitudPedido
			AND O.IdTipoOperacion = 2 --> CTE APROBACIÓN SOLPED
		INNER JOIN TA_TareaOperacion  AS TTO (NOLOCK)
			ON O.IdOperacion = TTO.IdOperacion
		INNER JOIN TA_Tarea AS T (NOLOCK) 
			ON TTO.IdTarea = T.IdTarea
		INNER JOIN TA_TipoOperacion AS OT (NOLOCK) 
			ON O.IdTipoOperacion = OT.IdTipoOperacion
		INNER JOIN TA_Estatus AS E (NOLOCK) 
			ON O.IdEstatusOperacion = E.IdEstatus
		INNER JOIN TA_FlujoTarea FT  (NOLOCK) 
			ON O.IdFlujoTarea = FT.IdFlujoTarea
		INNER JOIN TA_TipoFlujoTarea TFT (NOLOCK) 
			ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
		LEFT JOIN Adinco..CO_Contrato C (NOLOCK) 
			ON SP.IdContrato = C.IdContrato
		LEFT JOIN Adinco..CO_AreaContractual AC (NOLOCK) 
			ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN S_Usuario U (NOLOCK) 
			ON T.IdAprobador = U.IdUsuario
		WHERE T.IdAprobador = @AprobadorActualId
				AND O.IdTipoOperacion = 2 --> CTE APROBACIÓN DE SOLPED
				AND O.IdProveedor = @ProveedorId
				AND ISNULL(O.IdEstatusEliminado, 0) <> 1  --> MOSTRAR NO ELIMINADAS 
	AND T.idestatus = 1 -->CTE TAREA EN APROBACIÓN 
		GROUP BY O.IdOperacion,
				O.IdDocumento,
				O.FechaRegistro,
				O.Descripcion,
				E.Nombre,
				O.IdEstatusEliminado,
				T.IdTarea,
				TFT.Nombre,
				AC.NombreAreaContractual,
				T.NoSecuencia,
				U.Nombre
		ORDER BY O.FechaRegistro DESC;

		

END

  