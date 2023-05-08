-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200206
-- Description:	BITACORA DE ACCESO
-- =============================================
CREATE PROCEDURE [dbo].[sp_Insert_AP_BitacoraRutaAcceso]
    @IdContrato INT,
    @IdUsuario INT,
	@Ruta VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

	INSERT INTO AP_BitacoraRutaAcceso
				(Ruta,
				IdUsuario,
				IdContrato,
				CreadoEl)
	VALUES(@Ruta,@IdUsuario,@IdContrato,GetDate());

END;
