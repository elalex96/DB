-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/18
-- Description:	Modifica la union entre contratos y puntos de entrega
-- =============================================
-- 20180615    Reyna Olvera   Modificado para el activo y recibir la variable de @nombre
CREATE PROCEDURE [dbo].[CO_ModificaPuntosdeEntregaContrato]
	-- Add the parameters for the stored procedure here
	--@PuntoEntregaID int,
	@Nombre int,
	@idContrato int,
	@PuntoEntregaContratoID int,
	@idUsuario int

AS
BEGIN
	
-----------------------------Con Nombre----------------------

	SET NOCOUNT ON;
	Declare @cont int;
    
	SELECT @cont=COUNT(puntoEntregaContratoID) FROM  CO_PuntosdeEntregaContrato 
	Where PuntoEntregaID=@Nombre and idContrato=@idContrato;

	if(@cont>=1)
	begin
--	Print('Ya hay una relacion parecida.');

	UPDATE CO_PuntosdeEntregaContrato 
		SET Activo=1
	Where PuntoEntregaID=@Nombre and idContrato=@idContrato;

	End
	Else
	Begin
    
	UPDATE CO_PuntosdeEntregaContrato 
		SET PuntoEntregaID = @Nombre, idContrato = @idContrato,ModificadoPor=@idUsuario,ModificadoEl=getDate()
		WHERE (PuntoEntregaContratoID = @PuntoEntregaContratoID);
	end


END