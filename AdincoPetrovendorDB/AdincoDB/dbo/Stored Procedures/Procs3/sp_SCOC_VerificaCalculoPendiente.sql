CREATE PROCEDURE [dbo].[sp_SCOC_VerificaCalculoPendiente] --10010,10061,'2018-11-25'
    
    @idContrato INT,
    @idUsuario INT,
	@Mes Date
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2018097
-- Description:	Verifica si hay un calculo pendiente en ese mes
-- 20190209	BAAC	Se modifica para bucar el ultimo calculo pendiente, buscando en los ultimos 2 meses
-- =============================================
    SET NOCOUNT ON;

	CREATE TABLE #CalculosPendientes
	(
		resp	INT,
		MesReporte	DATE,
		idContrato	INT
	)

	Declare @primerDiaMes date;
	Select @primerDiaMes=primerDiaMes from ap_calendario where idFecha=DATEADD(MONTH, -2, @Mes)

	INSERT INTO #CalculosPendientes
	(
		resp,
		MesReporte,
		idContrato
	)
    SELECT  COUNT(1) as resp, MesReporte,EN.IdContrato as idContrato
    FROM SCOC_EnvioNotificacion EN
	JOIN dbo.CO_Contrato C
            ON EN.IdContrato = C.idContrato
	JOIN dbo.AP_PermisosUsuarios ON AP_PermisosUsuarios.UsuarioID=@idUsuario and AP_PermisosUsuarios.IdPermiso IN(6,8,9,10)
    WHERE MesReporte BETWEEN @primerDiaMes AND @Mes
		 And EN.idContrato=@idContrato
		Group by MesReporte,EN.IdContrato


	SELECT TOP 1
		resp,
		MesReporte,
		idContrato
	FROM #CalculosPendientes
	ORDER BY MesReporte DESC

END;

