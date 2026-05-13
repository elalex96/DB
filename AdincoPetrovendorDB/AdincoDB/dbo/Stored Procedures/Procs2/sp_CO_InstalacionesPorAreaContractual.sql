-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2 Diciembre 2014
-- Description:	Obtiene todas las instalaciones para registro
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_InstalacionesPorAreaContractual] 
	-- Add the parameters for the stored procedure here
@IdContrato INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT I.IdInstalacion,
                I.NombreInstalacion,
                 ISNULL(I.IdInstalacionPemex, 'Sin ID') as IdInstalacionPemex,
                I.EsBolsa,
               A.ID_CATACTIV,
               A.NombreActividad AS Actividad,
                I.NombreInstalacionAlterno
         FROM CO_Instalacion I
              INNER JOIN CO_ActividadCIEP A ON I.IdActividad =A.IdActividad
         WHERE(I.Activo = 1)
         ORDER BY I.IdActividad,
                  I.NombreInstalacion;
     END;
	--[sp_CO_InstalacionesPorAreaContractual] 10007

