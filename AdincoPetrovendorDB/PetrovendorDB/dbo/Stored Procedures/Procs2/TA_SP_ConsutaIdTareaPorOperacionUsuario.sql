USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'TA_SP_ConsutaIdTareaPorOperacionUsuario'
)
DROP PROCEDURE TA_SP_ConsutaIdTareaPorOperacionUsuario;
GO
/****** Object:  StoredProcedure [dbo].[TA_SP_ConsutaIdTareaPorOperacionUsuario]    Script Date: 26/08/2022 12:07:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Daniel AC
-- Create date: <09-01-2018>
-- Description:	<Recupero el IdTarea para la firma electronica
-- =============================================

CREATE procedure [dbo].[TA_SP_ConsutaIdTareaPorOperacionUsuario]
	@IdUsuario INT,
	@IdOperacion INT,
    @IdContrato    INT = null,   
    @FechaRegistro DATETIME = null

AS
BEGIN
	    SELECT T.IdTarea 
		FROM TA_Tarea AS T		
		WHERE IdAprobador = @IdUsuario 
		AND IdOperacion = @IdOperacion
END