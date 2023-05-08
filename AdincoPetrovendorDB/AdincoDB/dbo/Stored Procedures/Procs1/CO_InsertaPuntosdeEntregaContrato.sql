-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/18
-- Description:	Inserta la union de contratos con puntos de entrega
-- =============================================
-- 20180615    Reyna Olvera   Modificado para el activo y recibir la variable de @nombre
CREATE PROCEDURE [dbo].[CO_InsertaPuntosdeEntregaContrato]
	-- Add the parameters for the stored procedure here
	--@PuntoEntregaId int,
	@Nombre int,
	@idContrato int,
	@idUsuario int
	
AS
BEGIN

	SET NOCOUNT ON;
	--_-----------------------------------------------Con Nombre-----------------------

	Declare @cont int;
    
	SELECT @cont=COUNT(puntoEntregaContratoID) FROM  CO_PuntosdeEntregaContrato 
	Where PuntoEntregaID=@Nombre and idContrato=@idContrato;

	if(@cont>=1)
	begin
	--Print('Ya hay una relacion parecida.');

		Update CO_PuntosdeEntregaContrato 
		Set Activo=1
		Where PuntoEntregaID=@Nombre and idContrato=@idContrato;
	End
	Else
	Begin
		INSERT INTO CO_PuntosdeEntregaContrato(PuntoEntregaID, idContrato,CreadoPor,CreadoEl,Activo) 
			VALUES (@Nombre, @idContrato,@idUsuario,GetDate(),1);
	End
-------------------------------------------------------------------------------------------

END