-- =============================================
-- Author:		Miguel Gomez
-- Create date: 26-12-2016
-- Description:	Consulta las Actividades Subactividades de una Actividad Petrolera Anexo 4 Modalidad Licencia
-- =============================================
CREATE PROCEDURE sp_CO_ConsultaSubActividadesPetroleras 
	-- Add the parameters for the stored procedure here
	@IdActividadPetrolera int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT  DISTINCT    S.IdSubactividadPetrolera ,  S.[id_Sub-actividad] , S.SubactividadPetrolera  , '['+ S.[id_Sub-actividad]  + '] ' + S.SubactividadPetrolera  as NombreParaMostrar
FROM	CO_SubactividadPetrolera  S  
JOIN	CO_ActSubTareaPetroleraCNH AST
ON S.IdSubactividadPetrolera = AST.IdSubactividadPetrolera 
WHERE AST.IdActividadPetrolera = @IdActividadPetrolera 

END
