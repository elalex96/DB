-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/02/2023
-- Description:	Se consultan las solicitudes pendientes para descargar los archivos
-- =============================================
-- Author:		Luis David
-- Create date: 01/03/2023
-- Description:	Se filtra por tipo de pedido
-- =============================================
CREATE PROCEDURE SP_MM_SolicitudesPendientesDescargaProcura 
	@Tipo varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdSolicitud,
		FechaInicio,
		FechaFin,
		IdContrato,
		Tipo,
		IdUsuarioSolicitante
	FROM [MM_SolicitudesDescargaProcesos](NOLOCK)
	WHERE ISNULL(Procesado,0) = 0
	and Tipo = @Tipo
END