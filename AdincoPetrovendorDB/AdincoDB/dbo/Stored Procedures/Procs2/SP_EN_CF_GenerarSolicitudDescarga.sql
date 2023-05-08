-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/05/2022
-- Description:	Registro de solicitudes de descarga de rutas en contract files
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_CF_GenerarSolicitudDescarga]
	-- Add the parameters for the stored procedure here
	@Ruta NVARCHAR(MAX),
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO EN_CF_SolicitUDescargaCarpetas(
		SolicitadoPor,
		SolicitadoEl,
		ContratoId,
		RutaDescargada,
		Procesado
	)
	VALUES
	(	
		@IdUsuario,
		GETDATE(),
		@IdContrato,
		@Ruta,
		0
	);

	SELECT SCOPE_IDENTITY();

END
