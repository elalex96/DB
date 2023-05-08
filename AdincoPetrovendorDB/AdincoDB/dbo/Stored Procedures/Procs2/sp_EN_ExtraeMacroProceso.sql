-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20191030
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeMacroProceso] --3,10061,10001
    @idContrato INT,
    @idUsuario INT,
    @idMacroproceso INT
	AS
BEGIN
    SET NOCOUNT ON;

	Select NombreProceso,Descripcion,IdInstalacion 
	from EN_Procesos where IdProceso=@idMacroproceso
END