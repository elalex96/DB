-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Extrae las actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeActividadPorID]
    @idContrato INT,
    @idUsuario INT ,
	@IdActividad INT
AS
BEGIN
    SET NOCOUNT ON;
	Select NombreActividad,Dias,DiasNaturales,ISNULL(IdRegulador,0) AS IdRegulador from EN_Actividades where idActividad=@IdActividad
END;



