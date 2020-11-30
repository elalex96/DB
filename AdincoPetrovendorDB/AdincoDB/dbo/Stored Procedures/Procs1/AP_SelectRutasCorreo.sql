-- =============================================
-- Author:		Reyna Olvera
-- Create date: 03-08-2018
-- Description: Extrae las rutas
-- =============================================
CREATE PROCEDURE AP_SelectRutasCorreo
	
@IdUsuario INT=0,
@idContrato INT=0 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT idRuta,Ruta FROM ap_rutas
END
