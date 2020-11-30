-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama los procesos sin instalacion
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeProcesosParaMacro]--3,10061
	@idContrato INT,
	@idUsuario INT,
	@MacroProceso INT
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @TipoProceso INT=0;
	SELECT @TipoProceso=idTipoProceso FROM EN_PROCESOS WHERE idProceso=@MacroProceso

	if(@TipoProceso<>10002)
	BEGIN
		SELECT p.IdProceso,NombreProceso,Descripcion,idinstalacion,IsProcesoEvento
		FROM EN_Procesos p
		 JOIN en_procesosContrato PC ON PC.idProceso= p.IdProceso
			  WHERE PC.idContrato=@idContrato AND idTipoProceso=10000
		 AND p.Activo=1 AND p.IdInstalacion IS NOT NULL
	 END
	 ELSE
	 BEGIN
	 SELECT p.IdProceso,NombreProceso,Descripcion,idinstalacion,IsProcesoEvento
		FROM EN_Procesos p
		 JOIN en_procesosContrato PC ON PC.idProceso= p.IdProceso
			  WHERE PC.idContrato=@idContrato AND idTipoProceso=10000
		 AND p.Activo=1 AND p.IdInstalacion IS  NULL
	 END
END


