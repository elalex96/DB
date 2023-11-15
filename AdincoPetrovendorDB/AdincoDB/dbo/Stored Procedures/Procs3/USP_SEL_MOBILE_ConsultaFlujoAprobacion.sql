USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_MOBILE_ConsultaFlujoAprobacion'
)
    DROP PROCEDURE USP_SEL_MOBILE_ConsultaFlujoAprobacion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <14/11/2023>
-- Description:	<Consultar flujo de aprobacion de solicitud de pedido y pedido con el idoperacion>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_MOBILE_ConsultaFlujoAprobacion]
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@TipoOperacion INT,
	@IdUsuario INT = NULL,
	@IdContrato INT = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT
		EFT.Nombre AS EstatusOperacion,
		CASE
			WHEN OP.IdEstatusOperacion = 1 THEN '#e6ca5c'
			WHEN OP.IdEstatusOperacion = 2 THEN '#36eb83'
			WHEN OP.IdEstatusOperacion = 3 THEN '#ed594a'
			WHEN OP.IdEstatusOperacion = 4 THEN '#c0392b'
			ELSE '#ebede'
		END AS ColorBackground,
		T.IdTarea,
		OP.IdEstatusOperacion,
		US.Nombre,
		US.Correo,
		T.IdEstatus,
		E.Nombre AS Estatus,
		CASE
			WHEN T.IdEstatus = 1 THEN '#f4d03f'
			WHEN T.IdEstatus = 2 THEN '#2ecc71'
			WHEN T.IdEstatus = 3 THEN '#c0392b'
			WHEN T.IdEstatus = 4 THEN '#c0392b'
			ELSE '#ebedef'
		END AS Color,
		CASE
			WHEN T.IdEstatus = 1 THEN 'estatus_enaprobacion.png'
			WHEN T.IdEstatus = 2 THEN 'estatus_aprobado.png'
			WHEN T.IdEstatus = 3 THEN 'estatus_rechazado.png'
			WHEN T.IdEstatus = 4 THEN 'estatus_cancelado.png"'
			ELSE 'estatus_enaprobacion.png'
		END AS ImageEstatus
	FROM Petrovendor..TA_Tarea AS T (NOLOCK)
		JOIN Petrovendor..TA_Operacion AS OP (NOLOCK)
			ON T.IdOperacion = OP.IdOperacion
			AND OP.IdOperacion = @IdOperacion
			AND OP.IdTipoOperacion = @TipoOperacion
		JOIN Petrovendor..S_Usuario AS US (NOLOCK)
			ON T.IdAprobador = US.IdUsuario
		JOIN Petrovendor..TA_Estatus AS E (NOLOCK)
			ON T.IdEstatus = E.IdEstatus
		JOIN Petrovendor..TA_Estatus AS EFT (NOLOCK)
			ON OP.IdEstatusOperacion = EFT.IdEstatus
	ORDER BY T.NoSecuencia ASC;

END
