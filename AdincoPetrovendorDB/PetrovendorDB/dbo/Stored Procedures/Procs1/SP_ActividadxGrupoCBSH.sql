-- =============================================
-- Author:		<Alexander G>
-- Create date: <27/07/2017>
-- Description:	<Procedimiento para crear tabla para obtener las actividades correspondientes a un grupo especifico>
-- =============================================


CREATE PROCEDURE [dbo].[SP_ActividadxGrupoCBSH]
-- Add the parameters for the stored procedure here
      @IdGrupoCBSH INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here
		  CREATE TABLE #GruposActividad(IdActidad int, Nombre varchar(MAX))
		 INSERT INTO #GruposActividad(IdActidad, Nombre)VALUES(0,'-- Seleccione un familia --')
		 
		 INSERT INTO  #GruposActividad
         SELECT IdActidad , Nombre FROM MM_BS_Actividad
         WHERE IdGrupo = @IdGrupoCBSH
               AND
               Activo = 1
         ORDER BY IdActidad ASC;

		  SELECT IdActidad , Nombre FROM #GruposActividad  ORDER BY IdActidad ASC;
     END;
