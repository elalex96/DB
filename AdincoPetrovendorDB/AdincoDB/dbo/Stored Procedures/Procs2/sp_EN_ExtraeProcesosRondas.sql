-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama los procesos relacionados con las rondas
-- =============================================
create PROCEDURE sp_EN_ExtraeProcesosRondas
	@idContrato INT,
	@idUsuario INT,
	@IdRonda INT
AS
BEGIN

	SET NOCOUNT ON;

	
SELECT ISNULL(MR.Activo,0) AS Activo,
		M.IdProceso AS IdProceso,
		NombreProceso,
		Descripcion
FROM EN_Procesos M
LEFT JOIN EN_ProcesosRondas MR ON M.idProceso= MR.IdProceso AND MR.IdRonda =@idRonda

END