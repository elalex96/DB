-- =============================================
-- Author:		Miguel Gomez
-- Create date: 26-12-2016
-- Description:	Consulta las Actividades Petroleras Anexo 4 Modalidad Licencia
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaActividadesPetroleras] 
	-- Add the parameters for the stored procedure here
	@IdPeriodoContrato int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        IdActividadPetrolera, id_Actividad, DescripcionActividadPetrolera , '['+ id_Actividad + '] ' + DescripcionActividadPetrolera as NombreParaMostrar
FROM            CO_ActividadPetroleraCNH
END
