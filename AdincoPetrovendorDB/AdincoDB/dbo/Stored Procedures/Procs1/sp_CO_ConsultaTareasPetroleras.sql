-- =============================================
-- Author:		Miguel Gomez
-- Create date: 26-12-2016
-- Description:	Consulta las Tareas Petroleras de una SubActividad Petrolera Anexo 4 Modalidad Licencia
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaTareasPetroleras] 
	-- Add the parameters for the stored procedure here
	@IdSubActividadPetrolera int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT  DISTINCT    T.IdTareaPetrolera  , T.id_Tarea  , T.TareaPetrolera   , '['+ T.id_Tarea   + '] ' + T.TareaPetrolera   as NombreParaMostrar
FROM	CO_TareaPetrolera   T  
JOIN	CO_ActSubTareaPetroleraCNH AST
ON T.IdTareaPetrolera  = AST.IdTareaPetrolera  
WHERE AST.IdSubactividadPetrolera   = @IdSubActividadPetrolera  

END
