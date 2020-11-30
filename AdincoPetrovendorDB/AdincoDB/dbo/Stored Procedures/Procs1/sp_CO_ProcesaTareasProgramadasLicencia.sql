-- =============================================
-- Author:		Miguel Gomez
-- Create date: 30-12-2016
-- Description:	Procesa las tareas programadas
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ProcesaTareasProgramadasLicencia] 
	-- Add the parameters for the stored procedure here
	@IdActividad int = 0, 
	@IdSubactividad int = 0,
	@IdTareaPetrolera int= 0,
	@Anios nvarchar(MAX),
	@Meses nvarchar(MAX),
	@Servicios Subtareas READONLY
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--	CREATE TYPE SubTareas AS TABLE 
--(
--    IdServicio INT, Volumen float, MONac float, MOExt float, BSNac float, BSExt float, Pozos nvarchar(MAX)
--)
SELECT        A.id_Actividad, A.DescripcionActividadPetrolera, S.[id_Sub-actividad], S.SubactividadPetrolera, 
                         T.id_Tarea, T.TareaPetrolera , AN.Item AS Anio, M.Item AS Mes
FROM            CO_ActividadPetroleraCNH A CROSS JOIN
                         CO_SubactividadPetrolera S CROSS JOIN
                         CO_TareaPetrolera T CROSS JOIN
						 dbo.DelimitedSplit(@Meses ,',') M  CROSS JOIN
						  dbo.DelimitedSplit(@Anios,',') AN   
						 WHERE 
						 A.IdActividadPetrolera =@IdActividad AND
						 S.IdSubactividadPetrolera =@IdSubactividad AND
						 T.IdTareaPetrolera =@IdSubactividad 



	
END
