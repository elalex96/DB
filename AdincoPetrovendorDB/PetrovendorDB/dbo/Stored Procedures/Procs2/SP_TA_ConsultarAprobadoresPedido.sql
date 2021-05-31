USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ConsultarAprobadoresPedido'
)
    DROP PROCEDURE SP_TA_ConsultarAprobadoresPedido;

/****** Object:  StoredProcedure [dbo].[SP_TA_ConsultarAprobadoresPedido]    Script Date: 24/05/2021 06:54:34 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 14-09-17
-- Description:	 Consultar Aprobadores recibiendo el IdOperador
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 20/03/2021
-- Description:	Se optimiza la consulta para la pantalla detalle_pedido del issue 984
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarAprobadoresPedido] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
				--Obtener la información del flujo 
		SELECT  U.IdUsuario, T.NoSecuencia, U.Nombre,TAE.Nombre, T.Comentario AS Descripcion, T.FechaCambioEstatus
		FROM TA_Tarea AS T
		INNER JOIN TA_Operacion AS TOO 
			ON T.IdOperacion = TOO.IdOperacion 
		INNER JOIN S_Usuario AS U 
			ON T.IdAprobador = u.IdUsuario 
		INNER JOIN TA_Estatus AS TAE 
			ON T.IdEstatus = TAE.IdEstatus 
		WHERE  TOO.IdOperacion = @IdOperacion
		AND T.Activo=1
		ORDER BY NoSecuencia ASC 
END


