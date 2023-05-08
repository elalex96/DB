-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Consultar Prioridades para Operaciones de Aprobación
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ConsultarPrioridad]
-- Add the parameters for the stored procedure here
@IdContrato INT=0,
@IdUsuario  INT = 0,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
	
		SELECT IdPrioridad, Prioridad, ISNULL(Activo,1) AS Activo 
		FROM dbo.MA_Prioridad
		WHERE ISNULL(Activo,1)=1
		ORDER BY Prioridad ASC 

END; 

