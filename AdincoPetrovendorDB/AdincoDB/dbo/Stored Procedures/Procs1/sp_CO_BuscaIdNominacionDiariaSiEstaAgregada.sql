-- =============================================
-- Author:		Reyna Olvera
-- Create date: 23/02/2018
-- Description:	Verifica si ya esta insertado el volumen  de ese contrato y fecha
-- =============================================
CREATE PROCEDURE sp_CO_BuscaIdNominacionDiariaSiEstaAgregada
	-- Add the parameters for the stored procedure here
	@fechaMesDiaAño date,
	@hidrocarburo int,
	@PuntoEntrega int,
	@idContrato int,
	@idUsuario int=0
AS
BEGIN
--
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select idNominacionVolumenDiario,VolumenProgramado,idTipoBase,idUnidadMedida,comentario
	 from CO_NominacionDiaria where
	 idFecha= @fechaMesDiaAño and
	 idProductoNominacion=@hidrocarburo and 
	 @PuntoEntrega=@PuntoEntrega and 
	 idContrato=@idContrato

END

