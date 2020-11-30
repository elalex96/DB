CREATE	PROCEDURE [db_owner].[sp_ComboTipoMoneda]
AS 
BEGIN
	SELECT IdMoneda,TipoMoneda FROM dbo.PV_TipoMoneda WHERE Eliminado = 1
END	

