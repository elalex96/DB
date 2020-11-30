-- =============================================
-- Author:		Reyna  Olvera
-- Create date: 23/02/2018
-- Description:	Modifica la nominacion Diaria dependiendo el id
-- =============================================
CREATE PROCEDURE [dbo].[CO_ModificaNominacionDiaria]

	@tipoBase int ,
	@VolumenProgramado float,
	@UnidadMedida int,
	@idContrato int,
	@comentario nvarchar(Max),
	@idUsuario int,
	@idNominacionVolumenDiario int,
	@fechaMesDiaAño date,
	@puntoEntrega int,
	@hidrocarburo int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    -- Insert statements for procedure here
	--Select * from CO_NominacionDiaria
	Update CO_NominacionDiaria
	Set VolumenProgramado=@VolumenProgramado, 
	idTipoBase=@tipoBase,
	idUnidadMedida=@UnidadMedida,
	comentario=@comentario,
	ModificadoPor=@idUsuario,
	ModificadoEl= GETDATE()
	Where idNominacionVolumenDiario=@idNominacionVolumenDiario 
	and idContrato=@idContrato 
	and idFecha=@fechaMesDiaAño
	and PuntoEntregaId=@puntoEntrega
	and idProductoNominacion =@hidrocarburo
END

