-- =============================================
-- Author:		Miguel Gomez
-- Create date: 26-12-2016
-- Description:	Lista los Rubros de Clasificacion del Gasto de acuerdo al Anexo 4
-- =============================================
CREATE PROCEDURE sp_CO_RubrosGastoLicencia 
	-- Add the parameters for the stored procedure here
	@IdActividad int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @IdActividad =0 
	BEGIN

	SELECT         CO_ActividadPetroleraCNH.IdActividadPetrolera, CO_ActividadPetroleraCNH.id_Actividad, CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         CO_SubactividadPetrolera.IdSubactividadPetrolera, CO_SubactividadPetrolera.[id_Sub-actividad], CO_SubactividadPetrolera.SubactividadPetrolera, CO_TareaPetrolera.IdTareaPetrolera, 
                         CO_TareaPetrolera.id_Tarea, CO_TareaPetrolera.TareaPetrolera
FROM            CO_ActSubTareaPetroleraCNH INNER JOIN
                         CO_ActividadPetroleraCNH ON CO_ActSubTareaPetroleraCNH.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera INNER JOIN
                         CO_SubactividadPetrolera ON CO_ActSubTareaPetroleraCNH.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera INNER JOIN
                         CO_TareaPetrolera ON CO_ActSubTareaPetroleraCNH.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
						 END
						 ELSE
						 BEGIN
						 	SELECT         CO_ActividadPetroleraCNH.IdActividadPetrolera, CO_ActividadPetroleraCNH.id_Actividad, CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         CO_SubactividadPetrolera.IdSubactividadPetrolera, CO_SubactividadPetrolera.[id_Sub-actividad], CO_SubactividadPetrolera.SubactividadPetrolera, CO_TareaPetrolera.IdTareaPetrolera, 
                         CO_TareaPetrolera.id_Tarea, CO_TareaPetrolera.TareaPetrolera
FROM            CO_ActSubTareaPetroleraCNH INNER JOIN
                         CO_ActividadPetroleraCNH ON CO_ActSubTareaPetroleraCNH.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera INNER JOIN
                         CO_SubactividadPetrolera ON CO_ActSubTareaPetroleraCNH.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera INNER JOIN
                         CO_TareaPetrolera ON CO_ActSubTareaPetroleraCNH.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera

						 WHERE CO_ActividadPetroleraCNH.IdActividadPetrolera = @IdActividad  

						 END

				
END
