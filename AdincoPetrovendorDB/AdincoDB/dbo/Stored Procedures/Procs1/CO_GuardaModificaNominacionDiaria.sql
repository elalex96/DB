-- =============================================
-- Author:		Reyna Olvera
-- Create date: 22/02/18
-- Description:Realiza las operaciones acerca de la nominacion diaria
-- =============================================
CREATE PROCEDURE [dbo].[CO_GuardaModificaNominacionDiaria]
	-- Add the parameters for the stored procedure here
	@fechaMesDiaAño date,
	@hidrocarburo int,
	@PuntoEntrega int,
	@tipoBase int ,
	@VolumenProgramado float,
	@UnidadMedida int,
	@idContrato int,
	@comentario nvarchar(Max)=null,
	@idUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
    -- Insert statements for procedure here


	----
	
	

	

	insert into CO_NominacionDiaria([idFecha],[idProductoNominacion],[PuntoEntregaID],[idTipoBase],[VolumenProgramado],[idUnidadMedida],[idContrato],[Comentario],CreadoPor,CreadoEl) values(@fechaMesDiaAño,@hidrocarburo,@PuntoEntrega,@tipoBase,@VolumenProgramado,@UnidadMedida,@idContrato, @comentario,@idUsuario, GetDate());

END

