USE Petrovendor
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ConsultarHistorialXIdOperador'
)
    DROP PROCEDURE SP_TA_ConsultarHistorialXIdOperador;

/****** Object:  StoredProcedure [dbo].[SP_TA_ConsultarHistorialXIdOperador]    Script Date: 26/04/2022 06:43:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarHistorialXIdOperador] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
				--Obtener la información del flujo 
			SELECT  TH.Fecha,EF.NombreEstado,TH.Descripcion
			FROM TA_HistorialFlujoTarea AS TH  (NOLOCK)
			JOIN TA_EstadoFlujoTarea AS EF  (NOLOCK)
				ON TH.IdEstadoFlujo = EF.IdEstado
			WHERE  TH.IdOperacion = @IdOperacion
			ORDER BY TH.Fecha ASC 
		
END