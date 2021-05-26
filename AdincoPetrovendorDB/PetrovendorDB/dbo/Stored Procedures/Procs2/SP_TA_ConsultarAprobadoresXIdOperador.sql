USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ConsultarAprobadoresXIdOperador'
)
    DROP PROCEDURE SP_TA_ConsultarAprobadoresXIdOperador;
/****** Object:  StoredProcedure [dbo].[SP_TA_ConsultarAprobadoresXIdOperador]    Script Date: 24/05/2021 05:19:54 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Consultar Aprobadores recibiendo el IdOperador
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarAprobadoresXIdOperador] 
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
			INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdTarea =T.IdTarea
			INNER JOIN TA_Operacion AS TOO ON TAO.IdOperacion = TOO.IdOperacion
			INNER JOIN S_Usuario AS U on u.IdUsuario = T.IdAprobador
			INNER JOIN TA_Estatus AS TAE ON TAE.IdEstatus = T.IdEstatus
			WHERE  TAO.IdOperacion = @IdOperacion
			AND T.Activo=1
			ORDER BY NoSecuencia ASC 
		
END




