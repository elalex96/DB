USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'ME_ValidarEvaluacionRespondida'
)
DROP PROCEDURE ME_ValidarEvaluacionRespondida;
GO
/****** Object:  StoredProcedure [dbo].[ME_ValidarEvaluacionRespondida]    Script Date: 26/08/2022 03:02:18 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE procedure [dbo].[ME_ValidarEvaluacionRespondida]
	@IdProveedorEvaluado INT,
	@IdMatrizEvaluacion INT,
	@IdPedido int
AS
BEGIN
	SELECT COUNT(IdRespuestas) 
		FROM dbo.ME_Respuestas  (NOLOCK)
		WHERE IdMatrizEvaluacion = @IdMatrizEvaluacion
			AND IdProveedorEvaluado = @IdProveedorEvaluado
			AND IdPedido = @IdPedido
END


